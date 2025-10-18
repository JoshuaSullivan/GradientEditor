import Foundation

/// The result returned when the gradient editor completes.
///
/// Use this enum to handle the outcome of gradient editing in your app's completion callback.
///
/// ## Topics
///
/// ### Result Cases
/// - ``saved(_:)``
/// - ``cancelled``
///
/// ## Example
/// ```swift
/// let viewModel = GradientEditViewModel(scheme: scheme) { result in
///     switch result {
///     case .saved(let scheme):
///         // Save the edited gradient scheme
///         saveGradient(scheme)
///     case .cancelled:
///         // User cancelled, no action needed
///         break
///     }
/// }
/// ```
public enum GradientEditorResult: Sendable {

    /// The user completed editing and saved the gradient.
    ///
    /// Contains the final ``GradientColorScheme`` with all edits applied.
    case saved(GradientColorScheme)

    /// The user cancelled editing without saving.
    ///
    /// No changes were made to the original gradient.
    case cancelled
}
