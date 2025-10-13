import CoreGraphics
import SwiftUI

/// Calculates layout geometry for the gradient editor based on view size and orientation.
struct GradientLayoutGeometry {
    /// The orientation of the gradient strip.
    enum Orientation {
        case vertical
        case horizontal
    }

    /// The available view size.
    let viewSize: CGSize

    /// The width of the gradient strip.
    let stripWidth: CGFloat = 100

    /// The current zoom level (1.0 = 100%, 4.0 = 400%).
    let zoomLevel: CGFloat

    /// The pan offset (0.0 - 1.0, where 0.5 is centered).
    let panOffset: CGFloat

    /// Determines the orientation based on aspect ratio.
    var orientation: Orientation {
        viewSize.width > viewSize.height ? .horizontal : .vertical
    }

    /// The length of the gradient strip (the scrollable axis).
    var stripLength: CGFloat {
        let length = orientation == .vertical ? viewSize.height : viewSize.width
        // Ensure we never return zero to avoid division by zero
        return max(length, 1.0)
    }

    /// The visible length of the gradient after zoom is applied.
    var visibleLength: CGFloat {
        stripLength / zoomLevel
    }

    /// The start position of the visible range (0.0 - 1.0 in gradient space).
    var visibleRangeStart: CGFloat {
        guard zoomLevel > 1.0 else { return 0.0 }
        let maxPan = 1.0 - (1.0 / zoomLevel)
        return panOffset * maxPan
    }

    /// The end position of the visible range (0.0 - 1.0 in gradient space).
    var visibleRangeEnd: CGFloat {
        visibleRangeStart + (1.0 / zoomLevel)
    }

    /// Converts a gradient position (0.0-1.0) to a view coordinate.
    /// - Parameter gradientPosition: Position in gradient space (0.0-1.0).
    /// - Returns: Position in view coordinates, or nil if outside visible range.
    func viewCoordinate(for gradientPosition: CGFloat) -> CGFloat? {
        // Check if position is in visible range
        guard gradientPosition >= visibleRangeStart && gradientPosition <= visibleRangeEnd else {
            return nil
        }

        // Convert to visible range (0.0-1.0 within visible portion)
        let relativePosition = (gradientPosition - visibleRangeStart) / (visibleRangeEnd - visibleRangeStart)

        // Scale to view coordinates
        return relativePosition * stripLength
    }

    /// Converts a view coordinate to a gradient position (0.0-1.0).
    /// - Parameter viewCoordinate: Position in view coordinates.
    /// - Returns: Position in gradient space (0.0-1.0).
    func gradientPosition(from viewCoordinate: CGFloat) -> CGFloat {
        // Convert view coordinate to relative position in visible range
        let relativePosition = viewCoordinate / stripLength

        // Convert to gradient space
        let gradientPos = visibleRangeStart + (relativePosition * (visibleRangeEnd - visibleRangeStart))

        // Clamp to valid range
        return max(0.0, min(1.0, gradientPos))
    }

    /// Frame for the gradient strip.
    var gradientStripFrame: CGRect {
        switch orientation {
        case .vertical:
            return CGRect(x: 0, y: 0, width: stripWidth, height: stripLength)
        case .horizontal:
            return CGRect(x: 0, y: 0, width: stripLength, height: stripWidth)
        }
    }

    /// Position offset for a drag handle at the given gradient position.
    /// - Parameter gradientPosition: Position in gradient space (0.0-1.0).
    /// - Returns: Offset for the drag handle, or nil if outside visible range.
    func handleOffset(for gradientPosition: CGFloat) -> CGSize? {
        guard let viewCoord = viewCoordinate(for: gradientPosition) else {
            return nil
        }

        switch orientation {
        case .vertical:
            // Handles are aligned to trailing edge in vertical mode
            return CGSize(width: stripWidth, height: viewCoord)
        case .horizontal:
            // Handles are aligned to top edge in horizontal mode
            return CGSize(width: viewCoord, height: 0)
        }
    }
}
