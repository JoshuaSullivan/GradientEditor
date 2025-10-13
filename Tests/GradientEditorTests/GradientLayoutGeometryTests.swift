import Testing
import CoreGraphics
@testable import GradientEditor

@Suite("GradientLayoutGeometry Tests")
struct GradientLayoutGeometryTests {

    // MARK: - Orientation Tests

    @Test("Portrait orientation detected correctly")
    func portraitOrientation() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.orientation == .vertical)
    }

    @Test("Landscape orientation detected correctly")
    func landscapeOrientation() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 800, height: 400),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.orientation == .horizontal)
    }

    @Test("Square size defaults to vertical")
    func squareOrientation() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 500, height: 500),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.orientation == .vertical)
    }

    // MARK: - Strip Length Tests

    @Test("Strip length uses height for vertical orientation")
    func verticalStripLength() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.stripLength == 800)
    }

    @Test("Strip length uses width for horizontal orientation")
    func horizontalStripLength() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 800, height: 400),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.stripLength == 800)
    }

    @Test("Strip length has minimum value to prevent division by zero")
    func stripLengthMinimum() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 0, height: 0),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.stripLength >= 1.0)
    }

    // MARK: - Zoom Tests

    @Test("Visible range at 100% zoom")
    func noZoom() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        #expect(geometry.visibleRangeStart == 0.0)
        #expect(geometry.visibleRangeEnd == 1.0)
        #expect(geometry.visibleLength == 800)
    }

    @Test("Visible range at 200% zoom")
    func doubleZoom() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 2.0,
            panOffset: 0.0
        )

        #expect(geometry.visibleRangeStart == 0.0)
        #expect(geometry.visibleRangeEnd == 0.5)
        #expect(geometry.visibleLength == 400)
    }

    @Test("Visible range at 400% zoom")
    func quadrupleZoom() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 4.0,
            panOffset: 0.0
        )

        #expect(geometry.visibleRangeStart == 0.0)
        #expect(geometry.visibleRangeEnd == 0.25)
        #expect(geometry.visibleLength == 200)
    }

    // MARK: - Pan Tests

    @Test("Pan offset 0 shows start of gradient")
    func panStart() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 2.0,
            panOffset: 0.0
        )

        #expect(geometry.visibleRangeStart == 0.0)
        #expect(geometry.visibleRangeEnd == 0.5)
    }

    @Test("Pan offset 1 shows end of gradient")
    func panEnd() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 2.0,
            panOffset: 1.0
        )

        #expect(geometry.visibleRangeStart == 0.5)
        #expect(geometry.visibleRangeEnd == 1.0)
    }

    @Test("Pan offset 0.5 shows middle of gradient")
    func panMiddle() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 2.0,
            panOffset: 0.5
        )

        let expectedStart = 0.25
        let expectedEnd = 0.75

        #expect(abs(geometry.visibleRangeStart - expectedStart) < 0.001)
        #expect(abs(geometry.visibleRangeEnd - expectedEnd) < 0.001)
    }

    // MARK: - Coordinate Conversion Tests

    @Test("viewCoordinate returns nil for position outside visible range")
    func viewCoordinateOutsideRange() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 2.0,
            panOffset: 0.0
        )

        // Visible range is 0.0 - 0.5
        let coordinate = geometry.viewCoordinate(for: 0.75)
        #expect(coordinate == nil)
    }

    @Test("viewCoordinate converts position within visible range")
    func viewCoordinateInRange() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        let coordinate = geometry.viewCoordinate(for: 0.5)
        #expect(coordinate == 400)
    }

    @Test("viewCoordinate at range boundaries")
    func viewCoordinateBoundaries() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        let startCoord = geometry.viewCoordinate(for: 0.0)
        let endCoord = geometry.viewCoordinate(for: 1.0)

        #expect(startCoord == 0)
        #expect(endCoord == 800)
    }

    @Test("gradientPosition converts view coordinate to position")
    func gradientPositionConversion() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        let position = geometry.gradientPosition(from: 400)
        #expect(position == 0.5)
    }

    @Test("gradientPosition clamps to valid range")
    func gradientPositionClamping() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        let negative = geometry.gradientPosition(from: -100)
        let overMax = geometry.gradientPosition(from: 1000)

        #expect(negative == 0.0)
        #expect(overMax == 1.0)
    }

    // MARK: - Handle Offset Tests

    @Test("handleOffset returns nil for position outside visible range")
    func handleOffsetOutsideRange() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 2.0,
            panOffset: 0.0
        )

        let offset = geometry.handleOffset(for: 0.75)
        #expect(offset == nil)
    }

    @Test("handleOffset for vertical orientation")
    func handleOffsetVertical() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        let offset = geometry.handleOffset(for: 0.5)
        #expect(offset?.width == 100) // stripWidth
        #expect(offset?.height == 400)
    }

    @Test("handleOffset for horizontal orientation")
    func handleOffsetHorizontal() {
        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 800, height: 400),
            zoomLevel: 1.0,
            panOffset: 0.0
        )

        let offset = geometry.handleOffset(for: 0.5)
        #expect(offset?.width == 400)
        #expect(offset?.height == 0)
    }
}
