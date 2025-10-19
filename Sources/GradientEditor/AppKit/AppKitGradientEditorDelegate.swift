#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import Foundation

/// A delegate protocol for receiving gradient editor events in AppKit applications.
///
/// Implement this protocol to receive callbacks when the user saves or cancels gradient editing.
/// This is an alternative to the completion handler pattern and may feel more natural for AppKit developers.
///
/// ## Topics
///
/// ### Delegate Methods
/// - ``gradientEditor(_:didSaveScheme:)``
/// - ``gradientEditorDidCancel(_:)``
///
/// ## Example
/// ```swift
/// class MyViewController: NSViewController, GradientEditorDelegate {
///     func presentGradientEditor() {
///         let editor = GradientEditorViewController(scheme: .wakeIsland)
///         editor.delegate = self
///         presentAsSheet(editor)
///     }
///
///     func gradientEditor(_ editor: GradientEditorViewController, didSaveScheme scheme: GradientColorScheme) {
///         // Save the edited gradient
///         saveGradient(scheme)
///         dismiss(editor)
///     }
///
///     func gradientEditorDidCancel(_ editor: GradientEditorViewController) {
///         // User cancelled editing
///         dismiss(editor)
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
