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
///     case .saved(let colorMap):
///         // Save the edited gradient
///         saveGradient(colorMap)
///     case .cancelled:
///         // User cancelled, no action needed
///         break
///     }
/// }
/// ```
public enum GradientEditorResult: Sendable {

    /// The user completed editing and saved the gradient.
    ///
    /// Contains the final ``ColorMap`` with all edits applied.
    case saved(ColorMap)

    /// The user cancelled editing without saving.
    ///
    /// No changes were made to the original gradient.
    case cancelled
}
