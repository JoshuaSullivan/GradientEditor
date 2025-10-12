import Foundation

/// Errors that can occur during gradient editing.
public enum GradientEditorError: Error, Sendable {
    /// The gradient has too few color stops (minimum 2 required).
    case insufficientColorStops

    /// A color stop position is invalid (must be between 0 and 1).
    case invalidStopPosition(position: CGFloat)

    /// Failed to encode the gradient.
    case encodingFailed(underlying: Error)

    /// Failed to decode the gradient.
    case decodingFailed(underlying: Error)
}

extension GradientEditorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .insufficientColorStops:
            return LocalizedString.errorInsufficientStops
        case .invalidStopPosition(let position):
            return LocalizedString.errorInvalidPosition(position)
        case .encodingFailed:
            return LocalizedString.errorEncodingFailed
        case .decodingFailed:
            return LocalizedString.errorDecodingFailed
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .insufficientColorStops:
            return LocalizedString.errorRecoveryAddStops
        case .invalidStopPosition:
            return LocalizedString.errorRecoveryAdjustPosition
        case .encodingFailed, .decodingFailed:
            return LocalizedString.errorRecoveryTryAgain
        }
    }
}
