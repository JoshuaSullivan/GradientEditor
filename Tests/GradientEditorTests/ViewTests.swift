import Testing
import SwiftUI
@testable import GradientEditor

@Suite("View Tests")
@MainActor
struct ViewTests {

    // MARK: - GradientEditView Tests

    @Test("GradientEditView initializes with view model")
    func gradientEditViewInitialization() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Create the view - should not crash
        _ = GradientEditView(viewModel: viewModel)

        // Verify view can be created
        #expect(viewModel.colorStops.count > 0)
    }

    @Test("GradientEditView handles minimal scheme")
    func gradientEditViewWithMinimalStops() {
        let stops = [
            ColorStop(position: 0.0, type: .single(CGColor(red: 0, green: 0, blue: 0, alpha: 1))),
            ColorStop(position: 1.0, type: .single(CGColor(red: 1, green: 1, blue: 1, alpha: 1)))
        ]
        let scheme = GradientColorScheme(
            name: "Minimal",
            description: "Two stops",
            colorMap: ColorMap(stops: stops)
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        _ = GradientEditView(viewModel: viewModel)

        #expect(viewModel.colorStops.count == 2)
    }

    @Test("GradientEditView handles complex scheme")
    func gradientEditViewWithComplexScheme() {
        let stops = [
            ColorStop(position: 0.0, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1))),
            ColorStop(position: 0.25, type: .dual(
                CGColor(red: 1, green: 0.5, blue: 0, alpha: 1),
                CGColor(red: 1, green: 1, blue: 0, alpha: 1)
            )),
            ColorStop(position: 0.5, type: .single(CGColor(red: 0, green: 1, blue: 0, alpha: 1))),
            ColorStop(position: 0.75, type: .dual(
                CGColor(red: 0, green: 0, blue: 1, alpha: 1),
                CGColor(red: 0.5, green: 0, blue: 0.5, alpha: 1)
            )),
            ColorStop(position: 1.0, type: .single(CGColor(red: 0, green: 0, blue: 0, alpha: 1)))
        ]
        let scheme = GradientColorScheme(
            name: "Complex",
            description: "Many stops with dual colors",
            colorMap: ColorMap(stops: stops)
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        _ = GradientEditView(viewModel: viewModel)

        #expect(viewModel.colorStops.count == 5)
    }

    @Test("GradientEditView with zoomed state")
    func gradientEditViewZoomed() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)
        viewModel.updateZoom(3.0)
        viewModel.updatePan(0.5)

        _ = GradientEditView(viewModel: viewModel)

        #expect(viewModel.zoomLevel == 3.0)
        #expect(viewModel.panOffset == 0.5)
    }

    @Test("GradientEditView with editing state")
    func gradientEditViewWithEditing() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Select a stop for editing
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)

        _ = GradientEditView(viewModel: viewModel)

        #expect(viewModel.isEditingStop == true)
        #expect(viewModel.selectedStop != nil)
    }

    // MARK: - ColorStopEditorView Tests

    @Test("ColorStopEditorView initializes with single color stop")
    func colorStopEditorViewSingleColor() {
        let stop = ColorStop(position: 0.5, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        _ = ColorStopEditorView(viewModel: viewModel)

        #expect(viewModel.isSingleColorStop == true)
        #expect(viewModel.position == 0.5)
    }

    @Test("ColorStopEditorView initializes with dual color stop")
    func colorStopEditorViewDualColor() {
        let stop = ColorStop(position: 0.3, type: .dual(
            CGColor(red: 0, green: 0, blue: 1, alpha: 1),
            CGColor(red: 0, green: 1, blue: 0, alpha: 1)
        ))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        _ = ColorStopEditorView(viewModel: viewModel)

        #expect(viewModel.isSingleColorStop == false)
        #expect(viewModel.position == 0.3)
    }

    @Test("ColorStopEditorView with canDelete enabled")
    func colorStopEditorViewCanDelete() {
        let stop = ColorStop(position: 0.5, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        viewModel.canDelete = true

        _ = ColorStopEditorView(viewModel: viewModel)

        #expect(viewModel.canDelete == true)
    }

    @Test("ColorStopEditorView with canDelete disabled")
    func colorStopEditorViewCannotDelete() {
        let stop = ColorStop(position: 0.5, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        viewModel.canDelete = false

        _ = ColorStopEditorView(viewModel: viewModel)

        #expect(viewModel.canDelete == false)
    }

    // MARK: - DragHandle Tests

    @Test("DragHandle initializes with view model")
    func dragHandleInitialization() {
        let stop = ColorStop(position: 0.5, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
        let viewModel = DragHandleViewModel(colorStop: stop)

        _ = DragHandle(viewModel: viewModel)

        #expect(viewModel.position == 0.5)
    }

    @Test("DragHandle in horizontal orientation")
    func dragHandleHorizontal() {
        let stop = ColorStop(position: 0.5, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
        let viewModel = DragHandleViewModel(colorStop: stop)

        _ = DragHandle(viewModel: viewModel, isHorizontal: true)

        #expect(viewModel.position == 0.5)
    }

    @Test("DragHandle at boundary positions")
    func dragHandleAtBoundaries() {
        let stop1 = ColorStop(position: 0.0, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
        let viewModel1 = DragHandleViewModel(colorStop: stop1)
        _ = DragHandle(viewModel: viewModel1)
        #expect(viewModel1.position == 0.0)

        let stop2 = ColorStop(position: 1.0, type: .single(CGColor(red: 0, green: 0, blue: 1, alpha: 1)))
        let viewModel2 = DragHandleViewModel(colorStop: stop2)
        _ = DragHandle(viewModel: viewModel2)
        #expect(viewModel2.position == 1.0)
    }

    @Test("DragHandle with dual color stop")
    func dragHandleWithDualColor() {
        let stop = ColorStop(position: 0.5, type: .dual(
            CGColor(red: 1, green: 0, blue: 0, alpha: 1),
            CGColor(red: 0, green: 0, blue: 1, alpha: 1)
        ))
        let viewModel = DragHandleViewModel(colorStop: stop)

        _ = DragHandle(viewModel: viewModel)

        #expect(viewModel.position == 0.5)
        if case .dual = viewModel.colorStopType {
            // Success - type is preserved
        } else {
            Issue.record("Expected dual color type")
        }
    }

    @Test("DragHandle with various single colors")
    func dragHandleWithColors() {
        let testColors: [(CGFloat, CGFloat, CGFloat)] = [
            (1.0, 0.0, 0.0),  // red
            (0.0, 1.0, 0.0),  // green
            (0.0, 0.0, 1.0),  // blue
            (0.0, 0.0, 0.0),  // black
            (1.0, 1.0, 1.0)   // white
        ]

        for (r, g, b) in testColors {
            let color = CGColor(red: r, green: g, blue: b, alpha: 1.0)
            let stop = ColorStop(position: 0.5, type: .single(color))
            let viewModel = DragHandleViewModel(colorStop: stop)
            _ = DragHandle(viewModel: viewModel)
            #expect(viewModel.position == 0.5)
        }
    }
}
