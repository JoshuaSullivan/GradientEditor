#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import SwiftUI

/// An AppKit view controller for editing gradients.
///
/// `GradientEditorViewController` provides AppKit applications with access to the gradient editing functionality
/// without requiring SwiftUI knowledge. It wraps the SwiftUI `GradientEditView` and provides an AppKit-friendly API.
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
/// class MyViewController: NSViewController {
///     func presentGradientEditor() {
///         let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
///             switch result {
///             case .saved(let scheme):
///                 self.saveGradient(scheme)
///             case .cancelled:
///                 print("User cancelled")
///             }
///             self.dismiss(editor)
///         }
///
///         // Present as sheet
///         presentAsSheet(editor)
///     }
/// }
/// ```
///
/// ## Example - Delegate Pattern
/// ```swift
/// class MyViewController: NSViewController, GradientEditorDelegate {
///     func presentGradientEditor() {
///         let editor = GradientEditorViewController(scheme: .wakeIsland)
///         editor.delegate = self
///         presentAsSheet(editor)
///     }
///
///     func gradientEditor(_ editor: GradientEditorViewController, didSaveScheme scheme: GradientColorScheme) {
///         saveGradient(scheme)
///         dismiss(editor)
///     }
///
///     func gradientEditorDidCancel(_ editor: GradientEditorViewController) {
///         dismiss(editor)
///     }
/// }
/// ```
@MainActor
public class GradientEditorViewController: NSViewController {

    // MARK: - Public Properties

    /// The delegate to receive gradient editor events.
    ///
    /// Set this property to receive callbacks when the user saves or cancels editing.
    /// This is an alternative to the completion handler pattern.
    public weak var delegate: GradientEditorDelegate?

    // MARK: - Private Properties

    private let viewModel: GradientEditViewModel
    private var hostingController: NSHostingController<GradientEditView>?
    private let completion: (@Sendable (GradientEditorResult) -> Void)?
    private var cancelButton: NSButton!
    private var saveButton: NSButton!

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
        setupViewModel()
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
        setupViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func loadView() {
        // Create the main container view
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 500))
        self.view = containerView

        // Create and configure hosting controller
        let swiftUIView = GradientEditView(viewModel: viewModel)
        let hosting = NSHostingController(rootView: swiftUIView)
        addChild(hosting)

        // Add hosting view
        let hostingView = hosting.view
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingView)

        // Create button container
        let buttonContainer = NSView()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonContainer)

        // Create cancel button
        cancelButton = NSButton()
        cancelButton.title = "Cancel"
        cancelButton.bezelStyle = .rounded
        cancelButton.target = self
        cancelButton.action = #selector(cancelTapped)
        cancelButton.keyEquivalent = "\u{1b}" // Escape key
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(cancelButton)

        // Create save button
        saveButton = NSButton()
        saveButton.title = "Save"
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r" // Return key
        saveButton.target = self
        saveButton.action = #selector(saveTapped)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(saveButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            // Hosting view fills top area
            hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: -16),

            // Button container at bottom
            buttonContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonContainer.heightAnchor.constraint(equalToConstant: 32),

            // Cancel button on left
            cancelButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            cancelButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            // Save button on right
            saveButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            saveButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            saveButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])

        self.hostingController = hosting
        self.title = viewModel.scheme.name
    }

    // MARK: - Setup

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

    /// Presents the gradient editor as a sheet from the specified view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to present from.
    ///
    /// ## Example
    /// ```swift
    /// let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
    ///     // Handle result
    /// }
    /// editor.presentAsSheet(from: self)
    /// ```
    public func presentAsSheet(from viewController: NSViewController) {
        viewController.presentAsSheet(self)
    }

    /// Presents the gradient editor as a modal window.
    ///
    /// - Parameters:
    ///   - window: The window to present from.
    ///
    /// ## Example
    /// ```swift
    /// let editor = GradientEditorViewController(scheme: .wakeIsland) { result in
    ///     // Handle result
    /// }
    /// editor.presentAsModalWindow(from: self.view.window)
    /// ```
    public func presentAsModalWindow(from window: NSWindow?) {
        guard let window = window else { return }

        let panel = NSPanel(contentViewController: self)
        panel.title = viewModel.scheme.name
        panel.styleMask = [.titled, .closable, .resizable]
        panel.setContentSize(NSSize(width: 600, height: 500))
        panel.center()

        window.beginSheet(panel) { _ in
            // Sheet dismissed
        }
    }
}
#endif
