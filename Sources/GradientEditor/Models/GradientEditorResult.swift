import Foundation

/// The result returned when the gradient editor completes.
public enum GradientEditorResult: Sendable {
    /// The user completed editing and saved the gradient.
    case saved(ColorMap)

    /// The user cancelled editing without saving.
    case cancelled
}
