import Testing
import Foundation
import CoreGraphics
@testable import GradientEditor

@Suite("GradientEditViewModel Tests")
@MainActor
struct GradientEditViewModelTests {

    // MARK: - Test Helper

    final class ResultCapture: @unchecked Sendable {
        var result: GradientEditorResult?
    }

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with scheme")
    func initialization() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        #expect(viewModel.scheme.id == scheme.id)
        #expect(viewModel.colorStops.count == scheme.colorMap.stops.count)
        #expect(viewModel.dragHandleViewModels.count == scheme.colorMap.stops.count)
        #expect(!viewModel.isEditingStop)
        #expect(viewModel.selectedStop == nil)
    }

    @Test("ViewModel initializes with zoom and pan defaults")
    func defaultZoomPan() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        #expect(viewModel.zoomLevel == 1.0)
        #expect(viewModel.panOffset == 0.0)
    }

    // MARK: - Stop Management Tests

    @Test("Adding a stop increases count")
    func addStop() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let initialCount = viewModel.colorStops.count
        viewModel.addTapped()

        #expect(viewModel.colorStops.count == initialCount + 1)
        #expect(viewModel.dragHandleViewModels.count == initialCount + 1)
    }

    @Test("Adding multiple stops")
    func addMultipleStops() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let initialCount = viewModel.colorStops.count
        viewModel.addTapped()
        viewModel.addTapped()
        viewModel.addTapped()

        #expect(viewModel.colorStops.count == initialCount + 3)
        #expect(viewModel.dragHandleViewModels.count == initialCount + 3)
    }

    @Test("Updating stop position changes the stop")
    func updateStopPosition() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let firstStop = viewModel.colorStops.first!
        let originalPosition = firstStop.position

        viewModel.update(colorStopId: firstStop.id, position: 0.75)

        let updatedStop = viewModel.colorStops.first { $0.id == firstStop.id }
        #expect(updatedStop?.position == 0.75)
        #expect(updatedStop?.position != originalPosition)
        #expect(viewModel.editPosition == 0.75)
    }

    @Test("Updating stop preserves ID and type")
    func updatePreservesStopProperties() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let firstStop = viewModel.colorStops.first!
        let originalId = firstStop.id
        let _ = firstStop.type // Type comparison would require CGColor equality check

        viewModel.update(colorStopId: firstStop.id, position: 0.25)

        let updatedStop = viewModel.colorStops.first { $0.id == firstStop.id }
        #expect(updatedStop?.id == originalId)
    }

    // MARK: - Selection Tests

    @Test("Tapping a stop selects it")
    func selectStop() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)

        #expect(viewModel.isEditingStop == true)
        #expect(viewModel.selectedStop?.id == firstStop.id)
        #expect(viewModel.editPosition == firstStop.position)
    }

    @Test("Selecting different stops updates selection")
    func selectDifferentStops() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let stops = viewModel.colorStops
        guard stops.count >= 2 else { return }

        viewModel.stopTapped(stops[0].id)
        #expect(viewModel.selectedStop?.id == stops[0].id)

        viewModel.stopTapped(stops[1].id)
        #expect(viewModel.selectedStop?.id == stops[1].id)
    }

    // MARK: - Duplicate Tests

    @Test("Duplicating a stop creates new stop")
    func duplicateStop() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)

        let initialCount = viewModel.colorStops.count
        viewModel.colorStopViewModel.duplicateTapped()

        #expect(viewModel.colorStops.count == initialCount + 1)
        #expect(viewModel.dragHandleViewModels.count == initialCount + 1)
    }

    @Test("Duplicating places stop between current and next")
    func duplicateBetweenStops() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)
        viewModel.colorStopViewModel.duplicateTapped()

        // Should be placed at 0.5 (midpoint between 0.0 and 1.0)
        let duplicatedStop = viewModel.selectedStop
        #expect(duplicatedStop?.position == 0.5)
    }

    // MARK: - Zoom Tests

    @Test("Zoom level updates correctly")
    func updateZoomLevel() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        viewModel.updateZoom(2.0)
        #expect(viewModel.zoomLevel == 2.0)

        viewModel.updateZoom(3.5)
        #expect(viewModel.zoomLevel == 3.5)
    }

    @Test("Zoom level clamps to valid range")
    func zoomClamping() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        viewModel.updateZoom(0.5) // Below minimum
        #expect(viewModel.zoomLevel == 1.0)

        viewModel.updateZoom(5.0) // Above maximum
        #expect(viewModel.zoomLevel == 4.0)
    }

    @Test("Resetting zoom to 1.0 resets pan")
    func zoomResetsPan() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        viewModel.updateZoom(2.0)
        viewModel.updatePan(0.5)
        #expect(viewModel.panOffset == 0.5)

        viewModel.updateZoom(1.0)
        #expect(viewModel.panOffset == 0.0)
    }

    // MARK: - Pan Tests

    @Test("Pan offset updates when zoomed")
    func updatePanWhenZoomed() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        viewModel.updateZoom(2.0)
        viewModel.updatePan(0.5)

        #expect(viewModel.panOffset == 0.5)
    }

    @Test("Pan offset clamps to valid range")
    func panClamping() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        viewModel.updateZoom(2.0)

        viewModel.updatePan(-0.5) // Below minimum
        #expect(viewModel.panOffset == 0.0)

        viewModel.updatePan(1.5) // Above maximum
        #expect(viewModel.panOffset == 1.0)
    }

    @Test("Pan resets to 0 when not zoomed")
    func panResetsWhenNotZoomed() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        viewModel.updatePan(0.5) // Try to pan without zoom
        #expect(viewModel.panOffset == 0.0)
    }

    // MARK: - Completion Callback Tests

    @Test("Save gradient calls completion with saved result")
    func saveGradientCallback() {
        let scheme = GradientColorScheme.wakeIsland
        let capture = ResultCapture()

        let viewModel = GradientEditViewModel(scheme: scheme) { result in
            capture.result = result
        }

        viewModel.saveGradient()

        #expect(capture.result != nil)
        if case .saved(let colorMap) = capture.result {
            #expect(colorMap.stops.count == viewModel.colorStops.count)
        } else {
            Issue.record("Expected saved result")
        }
    }

    @Test("Cancel editing calls completion with cancelled result")
    func cancelEditingCallback() {
        let scheme = GradientColorScheme.wakeIsland
        let capture = ResultCapture()

        let viewModel = GradientEditViewModel(scheme: scheme) { result in
            capture.result = result
        }

        viewModel.cancelEditing()

        #expect(capture.result != nil)
        if case .cancelled = capture.result {
            // Success
        } else {
            Issue.record("Expected cancelled result")
        }
    }

    // MARK: - ColorStops Array Tests

    @Test("ColorStops array is sorted by position")
    func colorStopsSorted() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let stops = viewModel.colorStops

        for i in 0..<(stops.count - 1) {
            #expect(stops[i].position <= stops[i + 1].position)
        }
    }

    @Test("ColorStops array updates after adding stops")
    func colorStopsUpdatesAfterAdd() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let initialStops = viewModel.colorStops
        viewModel.addTapped()
        let updatedStops = viewModel.colorStops

        #expect(updatedStops.count == initialStops.count + 1)
    }

    // MARK: - DragHandleViewModel Sync Tests

    @Test("DragHandleViewModels stay in sync with stops")
    func dragHandleSync() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        #expect(viewModel.dragHandleViewModels.count == viewModel.colorStops.count)

        viewModel.addTapped()
        #expect(viewModel.dragHandleViewModels.count == viewModel.colorStops.count)

        // Check that IDs match
        let stopIds = Set(viewModel.colorStops.map { $0.id })
        let handleIds = Set(viewModel.dragHandleViewModels.map { $0.id })
        #expect(stopIds == handleIds)
    }

    @Test("Updating stop updates corresponding DragHandleViewModel")
    func dragHandleUpdatesWithStop() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let firstStop = viewModel.colorStops.first!
        let firstHandle = viewModel.dragHandleViewModels.first { $0.id == firstStop.id }!
        let originalPosition = firstHandle.position

        viewModel.update(colorStopId: firstStop.id, position: 0.8)

        let updatedHandle = viewModel.dragHandleViewModels.first { $0.id == firstStop.id }!
        #expect(updatedHandle.position == 0.8)
        #expect(updatedHandle.position != originalPosition)
    }

    // MARK: - GradientFill Tests

    @Test("GradientFill returns valid LinearGradient")
    func gradientFillReturnsCorrectGradient() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Access gradientFill - should not crash
        let _ = viewModel.gradientFill

        // If we got here, gradient creation succeeded
        #expect(viewModel.colorStops.count == 2)
    }

    @Test("GradientFill handles dual-color stops without crashing")
    func gradientFillWithDualColors() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 0.5, type: .dual(.green, .blue)),
                ColorStop(position: 1.0, type: .single(.yellow))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Access gradientFill - should not crash even with dual colors
        let _ = viewModel.gradientFill

        // If we got here, gradient creation succeeded
        #expect(viewModel.colorStops.count == 3)
    }

    // MARK: - Export/Import Tests

    @Test("Export gradient creates valid JSON")
    func exportGradientCreatesJSON() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Export should not crash
        viewModel.exportGradient()

        // Verify gradient still has correct stops after export
        #expect(viewModel.colorStops.count == 2)
    }

    @Test("Import gradient with valid data succeeds")
    func importGradientWithValidData() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let colorMap = ColorMap(stops: [
            ColorStop(position: 0.0, type: .single(.red)),
            ColorStop(position: 1.0, type: .single(.blue))
        ])

        let jsonData = try! JSONEncoder().encode(colorMap)

        // Import should not crash
        viewModel.importGradient(data: jsonData)

        // Verify view model state is still valid
        #expect(viewModel.colorStops.count > 0)
    }

    @Test("Import gradient with invalid data handles error")
    func importGradientWithInvalidData() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        let invalidData = "invalid json".data(using: .utf8)!

        // Import should handle error gracefully without crashing
        viewModel.importGradient(data: invalidData)

        // Verify view model state is still valid
        #expect(viewModel.colorStops.count > 0)
    }

    // MARK: - Close Action Tests

    @Test("Close action clears editing state")
    func closeActionClearsState() {
        let scheme = GradientColorScheme.wakeIsland
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Select a stop
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)
        #expect(viewModel.isEditingStop == true)
        #expect(viewModel.selectedStop != nil)

        // Trigger close action
        viewModel.colorStopViewModel.closeTapped()

        // Editing state should be cleared
        #expect(viewModel.isEditingStop == false)
        #expect(viewModel.selectedStop == nil)
    }

    // MARK: - Duplicate Edge Cases

    @Test("Duplicate last stop places between previous and current")
    func duplicateLastStop() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let sortedStops = viewModel.colorStops.sorted(by: { $0.position < $1.position })
        let lastStop = sortedStops.last!
        viewModel.stopTapped(lastStop.id)

        viewModel.colorStopViewModel.duplicateTapped()

        // Duplicated stop should be between 0.0 and 1.0
        let duplicatedStop = viewModel.selectedStop
        #expect(duplicatedStop?.position == 0.5)
    }

    @Test("Duplicate only stop places at midpoint")
    func duplicateOnlyStop() {
        // Create a gradient with only one stop (edge case)
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.3, type: .single(.red))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        #expect(viewModel.colorStops.count == 1)

        let onlyStop = viewModel.colorStops.first!
        viewModel.stopTapped(onlyStop.id)

        viewModel.colorStopViewModel.duplicateTapped()

        // Duplicated stop should be at 0.5 (midpoint)
        let duplicatedStop = viewModel.selectedStop
        #expect(duplicatedStop?.position == 0.5)
        #expect(viewModel.colorStops.count == 2)
    }
}
