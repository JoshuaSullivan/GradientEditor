#if canImport(UIKit)
import UIKit
import SwiftUI

/// A UIKit view controller for editing gradients.
///
/// `GradientEditorViewController` provides UIKit applications with access to the gradient editing functionality
/// without requiring SwiftUI knowledge. It wraps the SwiftUI `GradientEditView` and provides a UIKit-friendly API.
///
/// The view controller supports two callback patterns:
/// - **Completion handler** (recommended): Passed during initialization
/// - **Delegate pattern**: Set the ``delegate`` property after initialization
///
/// You can use one or both patterns depending on your needs.
///
/// ## Topics
///
/// ### Creating the View Controller
/// - ``init(scheme:completion:)``
/// - ``init(scheme:)``
///
/// ### Delegate
/// - ``delegate``
///
/// ## Example - Completion Handler
/// ```swift
/// class MyViewController: UIViewController {
///     func presentGradientEditor() {
///         let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
///             switch result {
///             case .saved(let scheme):
///                 self.saveGradient(scheme)
///             case .cancelled:
///                 print("User cancelled")
///             }
///             self.dismiss(animated: true)
///         }
///
///         // For modal presentation, wrap in navigation controller
///         let nav = UINavigationController(rootViewController: editor)
///         present(nav, animated: true)
///     }
/// }
/// ```
///
/// ## Example - Delegate Pattern
/// ```swift
/// class MyViewController: UIViewController, GradientEditorDelegate {
///     func presentGradientEditor() {
///         let editor = GradientEditorViewController(scheme: .wakeIsland)
///         editor.delegate = self
///
///         let nav = UINavigationController(rootViewController: editor)
///         present(nav, animated: true)
///     }
///
///     func gradientEditor(_ editor: GradientEditorViewController, didSaveScheme scheme: GradientColorScheme) {
///         saveGradient(scheme)
///         dismiss(animated: true)
///     }
///
///     func gradientEditorDidCancel(_ editor: GradientEditorViewController) {
///         dismiss(animated: true)
///     }
/// }
/// ```
@MainActor
public class GradientEditorViewController: UIViewController {

    // MARK: - Public Properties

    /// The delegate to receive gradient editor events.
    ///
    /// Set this property to receive callbacks when the user saves or cancels editing.
    /// This is an alternative to the completion handler pattern.
    public weak var delegate: GradientEditorDelegate?

    // MARK: - Private Properties

    private let viewModel: GradientEditViewModel
    private var hostingController: UIHostingController<GradientEditView>?
    private let completion: (@Sendable (GradientEditorResult) -> Void)?

    // MARK: - Initialization

    /// Creates a gradient editor view controller with a completion handler.
    ///
    /// - Parameters:
    ///   - scheme: The gradient scheme to edit.
    ///   - completion: A closure called when editing completes (save or cancel).
    ///
    /// ## Example
    /// ```swift
    /// let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
    ///     switch result {
    ///     case .saved(let scheme):
    ///         print("Saved: \(scheme.name)")
    ///     case .cancelled:
    ///         print("Cancelled")
    ///     }
    /// }
    /// ```
    public init(scheme: GradientColorScheme, completion: @escaping @Sendable (GradientEditorResult) -> Void) {
        self.completion = completion
        self.viewModel = GradientEditViewModel(scheme: scheme) { @Sendable result in
            completion(result)
        }
        super.init(nibName: nil, bundle: nil)
        setupNavigationItems()
    }

    /// Creates a gradient editor view controller without a completion handler.
    ///
    /// Use this initializer if you prefer the delegate pattern. Set the ``delegate`` property
    /// to receive callbacks.
    ///
    /// - Parameter scheme: The gradient scheme to edit.
    ///
    /// ## Example
    /// ```swift
    /// let editor = GradientEditorViewController(scheme: .wakeIsland)
    /// editor.delegate = self
    /// ```
    public init(scheme: GradientColorScheme) {
        self.completion = nil
        self.viewModel = GradientEditViewModel(scheme: scheme)
        super.init(nibName: nil, bundle: nil)
        setupNavigationItems()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupHostingController()
        setupViewModel()
    }

    // MARK: - Setup

    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )

        // Set title from scheme name
        title = viewModel.scheme.name
    }

    private func setupHostingController() {
        let swiftUIView = GradientEditView(viewModel: viewModel)
        let hosting = UIHostingController(rootView: swiftUIView)

        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hosting.didMove(toParent: self)
        self.hostingController = hosting
    }

    private func setupViewModel() {
        // Override the view model's completion to also call delegate
        let originalCompletion = viewModel.onComplete
        viewModel.onComplete = { @Sendable [weak self, originalCompletion] result in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                // Call delegate if set
                switch result {
                case .saved(let scheme):
                    self.delegate?.gradientEditor(self, didSaveScheme: scheme)
                case .cancelled:
                    self.delegate?.gradientEditorDidCancel(self)
                }

                // Call original completion (which may call our completion handler)
                originalCompletion?(result)
            }
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        viewModel.cancelEditing()
    }

    @objc private func saveTapped() {
        viewModel.saveGradient()
    }

    // MARK: - Public Methods

    /// Presents the gradient editor modally from the specified view controller.
    ///
    /// The editor will be wrapped in a `UINavigationController` automatically.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to present from.
    ///   - animated: Whether to animate the presentation.
    ///   - completion: Optional closure called after presentation completes.
    ///
    /// ## Example
    /// ```swift
    /// let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
    ///     // Handle result
    /// }
    /// editor.presentModally(from: self)
    /// ```
    public func presentModally(
        from viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let navigationController = UINavigationController(rootViewController: self)
        viewController.present(navigationController, animated: animated, completion: completion)
    }

    /// Pushes the gradient editor onto the specified navigation controller.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller to push onto.
    ///   - animated: Whether to animate the push.
    ///
    /// ## Example
    /// ```swift
    /// let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
    ///     // Handle result
    /// }
    /// editor.pushOnto(navigationController: self.navigationController)
    /// ```
    public func pushOnto(navigationController: UINavigationController, animated: Bool = true) {
        navigationController.pushViewController(self, animated: animated)
    }
}
#endif
