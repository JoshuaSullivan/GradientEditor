#if canImport(UIKit)
import Foundation

/// A delegate protocol for receiving gradient editor events in UIKit applications.
///
/// Implement this protocol to receive callbacks when the user saves or cancels gradient editing.
/// This is an alternative to the completion handler pattern and may feel more natural for UIKit developers.
///
/// ## Topics
///
/// ### Delegate Methods
/// - ``gradientEditor(_:didSaveScheme:)``
/// - ``gradientEditorDidCancel(_:)``
///
/// ## Example
/// ```swift
/// class MyViewController: UIViewController, GradientEditorDelegate {
///     func presentGradientEditor() {
///         let editor = GradientEditorViewController(scheme: .wakeIsland)
///         editor.delegate = self
///         present(editor, animated: true)
///     }
///
///     func gradientEditor(_ editor: GradientEditorViewController, didSaveScheme scheme: GradientColorScheme) {
///         // Save the edited gradient
///         saveGradient(scheme)
///         editor.dismiss(animated: true)
///     }
///
///     func gradientEditorDidCancel(_ editor: GradientEditorViewController) {
///         // User cancelled editing
///         editor.dismiss(animated: true)
///     }
/// }
/// ```
@MainActor
public protocol GradientEditorDelegate: AnyObject {

    /// Called when the user saves the edited gradient.
    ///
    /// - Parameters:
    ///   - editor: The gradient editor view controller.
    ///   - scheme: The final gradient scheme with all edits applied.
    func gradientEditor(_ editor: GradientEditorViewController, didSaveScheme scheme: GradientColorScheme)

    /// Called when the user cancels editing without saving.
    ///
    /// - Parameter editor: The gradient editor view controller.
    func gradientEditorDidCancel(_ editor: GradientEditorViewController)
}
#endif
