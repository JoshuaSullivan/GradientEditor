import Testing
import Foundation
import CoreGraphics
import Combine
@testable import GradientEditor

@Suite("Integration Tests")
@MainActor
struct IntegrationTests {

    // MARK: - Test Helper

    final class ResultCapture: @unchecked Sendable {
        var result: GradientEditorResult?
    }

    final class ActionCapture: @unchecked Sendable {
        var actions: [ColorStopEditorViewModel.Action] = []
        var cancellables = Set<AnyCancellable>()
    }

    // MARK: - Complete Editing Workflow Tests

    @Test("Complete workflow: Create gradient, add stop, save")
    func completeWorkflowSave() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let capture = ResultCapture()
        let viewModel = GradientEditViewModel(scheme: scheme) { result in
            capture.result = result
        }

        let initialStopCount = viewModel.colorStops.count

        // Add a stop
        viewModel.addTapped()
        #expect(viewModel.colorStops.count == initialStopCount + 1)

        // Select and edit the first stop
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)
        #expect(viewModel.isEditingStop == true)
        #expect(viewModel.selectedStop?.id == firstStop.id)

        // Update position
        viewModel.update(colorStopId: firstStop.id, position: 0.25)
        let updatedStop = viewModel.colorStops.first { $0.id == firstStop.id }
        #expect(updatedStop?.position == 0.25)

        // Save
        viewModel.saveGradient()
        #expect(capture.result != nil)
        if case .saved(let savedScheme) = capture.result {
            #expect(savedScheme.colorMap.stops.count == initialStopCount + 1)
            #expect(savedScheme.name == scheme.name)
            #expect(savedScheme.description == scheme.description)
        } else {
            Issue.record("Expected saved result")
        }
    }

    @Test("Complete workflow: Create gradient, modify, cancel")
    func completeWorkflowCancel() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let capture = ResultCapture()
        let viewModel = GradientEditViewModel(scheme: scheme) { result in
            capture.result = result
        }

        // Make changes
        viewModel.addTapped()
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)
        viewModel.update(colorStopId: firstStop.id, position: 0.25)

        // Cancel
        viewModel.cancelEditing()
        #expect(capture.result != nil)
        if case .cancelled = capture.result {
            // Success
        } else {
            Issue.record("Expected cancelled result")
        }
    }

    @Test("Workflow: Add stop, select it, verify state")
    func addAndSelectWorkflow() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let initialCount = viewModel.colorStops.count

        // Add a stop
        viewModel.addTapped()
        #expect(viewModel.colorStops.count == initialCount + 1)

        // The new stop should be added
        let stops = viewModel.colorStops.sorted(by: { $0.position < $1.position })
        #expect(stops.count == initialCount + 1)

        // Select the newly added stop (should be somewhere in the middle)
        let middleStop = stops[1]
        viewModel.stopTapped(middleStop.id)
        #expect(viewModel.isEditingStop == true)
        #expect(viewModel.selectedStop?.id == middleStop.id)
    }

    // MARK: - Duplicate Workflow Tests

    @Test("Workflow: Select stop, duplicate, verify new stop")
    func duplicateWorkflow() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let initialCount = viewModel.colorStops.count

        // Select first stop
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)
        #expect(viewModel.isEditingStop == true)

        // Duplicate
        viewModel.colorStopViewModel.duplicateTapped()
        #expect(viewModel.colorStops.count == initialCount + 1)

        // Verify the duplicated stop is between original stops
        let duplicatedStop = viewModel.selectedStop
        #expect(duplicatedStop != nil)
        #expect(duplicatedStop?.position == 0.5)
    }

    @Test("Workflow: Duplicate stop maintains color type")
    func duplicateMaintainsColorType() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .dual(.red, .yellow)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Select first stop (dual color)
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)

        // Duplicate
        viewModel.colorStopViewModel.duplicateTapped()

        // Verify the duplicated stop has the same color type
        let duplicatedStop = viewModel.selectedStop
        #expect(duplicatedStop != nil)
        if case .dual(let firstColor, let secondColor) = duplicatedStop?.type {
            #expect(firstColor == .red)
            #expect(secondColor == .yellow)
        } else {
            Issue.record("Expected duplicated stop to be dual color")
        }
    }

    // MARK: - Delete Workflow Tests

    @Test("Workflow: Select stop, delete, verify removal")
    func deleteWorkflow() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 0.5, type: .single(.green)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let initialCount = viewModel.colorStops.count
        #expect(initialCount == 3)

        // Select middle stop
        let middleStop = viewModel.colorStops.sorted(by: { $0.position < $1.position })[1]
        let middleStopId = middleStop.id
        viewModel.stopTapped(middleStopId)
        #expect(viewModel.isEditingStop == true)

        // Delete
        viewModel.colorStopViewModel.deleteTapped()
        #expect(viewModel.colorStops.count == initialCount - 1)

        // Verify the stop is gone
        let deletedStop = viewModel.colorStops.first { $0.id == middleStopId }
        #expect(deletedStop == nil)
    }

    @Test("Workflow: Cannot delete when only two stops remain")
    func cannotDeleteMinimumStops() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        #expect(viewModel.colorStops.count == 2)

        // Select first stop
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)

        // Verify canDelete is false
        #expect(viewModel.colorStopViewModel.canDelete == false)

        // Try to delete - should not work
        viewModel.colorStopViewModel.deleteTapped()
        #expect(viewModel.colorStops.count == 2) // Still 2 stops
    }

    // MARK: - Navigation Workflow Tests

    @Test("Workflow: Navigate between stops with prev/next")
    func navigationWorkflow() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 0.5, type: .single(.green)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let sortedStops = viewModel.colorStops.sorted(by: { $0.position < $1.position })
        #expect(sortedStops.count == 3)

        // Select first stop
        viewModel.stopTapped(sortedStops[0].id)
        #expect(viewModel.selectedStop?.id == sortedStops[0].id)

        // Navigate to next
        viewModel.colorStopViewModel.nextTapped()
        #expect(viewModel.selectedStop?.id == sortedStops[1].id)

        // Navigate to next again
        viewModel.colorStopViewModel.nextTapped()
        #expect(viewModel.selectedStop?.id == sortedStops[2].id)

        // Navigate back
        viewModel.colorStopViewModel.prevTapped()
        #expect(viewModel.selectedStop?.id == sortedStops[1].id)
    }

    @Test("Workflow: Navigation wraps at boundaries")
    func navigationWrapping() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let sortedStops = viewModel.colorStops.sorted(by: { $0.position < $1.position })

        // Select first stop
        viewModel.stopTapped(sortedStops[0].id)
        #expect(viewModel.selectedStop?.id == sortedStops[0].id)

        // Navigate prev from first (should wrap to last)
        viewModel.colorStopViewModel.prevTapped()
        #expect(viewModel.selectedStop?.id == sortedStops[1].id)

        // Navigate next from last (should wrap to first)
        viewModel.colorStopViewModel.nextTapped()
        #expect(viewModel.selectedStop?.id == sortedStops[0].id)
    }

    // MARK: - Zoom and Pan Workflow Tests

    @Test("Workflow: Zoom in, pan, position stop")
    func zoomPanPositionWorkflow() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Initial state
        #expect(viewModel.zoomLevel == 1.0)
        #expect(viewModel.panOffset == 0.0)

        // Zoom in
        viewModel.updateZoom(2.0)
        #expect(viewModel.zoomLevel == 2.0)

        // Pan
        viewModel.updatePan(0.5)
        #expect(viewModel.panOffset == 0.5)

        // Add a stop
        viewModel.addTapped()
        let newStopCount = viewModel.colorStops.count
        #expect(newStopCount == 3)

        // Zoom back to 1.0 (should reset pan)
        viewModel.updateZoom(1.0)
        #expect(viewModel.zoomLevel == 1.0)
        #expect(viewModel.panOffset == 0.0)
    }

    // MARK: - ColorStopEditorViewModel Integration Tests

    @Test("Integration: ColorStopEditorViewModel actions update GradientEditViewModel")
    func editorViewModelActionsIntegration() async {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Select a stop
        let firstStop = viewModel.colorStops.first!
        viewModel.stopTapped(firstStop.id)

        let editorViewModel = viewModel.colorStopViewModel
        let actionCapture = ActionCapture()

        // Subscribe to actions
        editorViewModel.actionPublisher.sink { action in
            actionCapture.actions.append(action)
        }.store(in: &actionCapture.cancellables)

        // Change position via editor
        editorViewModel.position = 0.25

        try? await Task.sleep(for: .milliseconds(10))

        // Verify action was published
        #expect(actionCapture.actions.count >= 1)
        if case .updatedStop(let updatedStop) = actionCapture.actions.first {
            #expect(updatedStop.position == 0.25)
        }
    }

    @Test("Integration: Multiple edits in sequence maintain consistency")
    func multipleEditsConsistency() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        // Add stop
        viewModel.addTapped()
        let countAfterAdd = viewModel.colorStops.count
        #expect(countAfterAdd == 3)

        // Select and edit first stop
        let firstStop = viewModel.colorStops.sorted(by: { $0.position < $1.position }).first!
        viewModel.stopTapped(firstStop.id)
        viewModel.update(colorStopId: firstStop.id, position: 0.1)

        // Verify update
        let updatedStop = viewModel.colorStops.first { $0.id == firstStop.id }
        #expect(updatedStop?.position == 0.1)

        // Duplicate
        viewModel.colorStopViewModel.duplicateTapped()
        let countAfterDuplicate = viewModel.colorStops.count
        #expect(countAfterDuplicate == 4)

        // Verify all drag handles are in sync
        #expect(viewModel.dragHandleViewModels.count == viewModel.colorStops.count)

        let stopIds = Set(viewModel.colorStops.map { $0.id })
        let handleIds = Set(viewModel.dragHandleViewModels.map { $0.id })
        #expect(stopIds == handleIds)
    }

    @Test("Integration: Save preserves all modifications")
    func savePreservesModifications() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let capture = ResultCapture()
        let viewModel = GradientEditViewModel(scheme: scheme) { result in
            capture.result = result
        }

        // Add stop
        viewModel.addTapped()

        // Edit first stop position
        let firstStop = viewModel.colorStops.sorted(by: { $0.position < $1.position }).first!
        viewModel.stopTapped(firstStop.id)
        viewModel.update(colorStopId: firstStop.id, position: 0.15)

        // Edit second stop to dual color
        let sortedStops = viewModel.colorStops.sorted(by: { $0.position < $1.position })
        let secondStop = sortedStops[1]
        viewModel.stopTapped(secondStop.id)

        // Change to dual color via editor
        let editorVM = viewModel.colorStopViewModel
        editorVM.isSingleColorStop = false
        editorVM.secondColor = .green

        // Save
        viewModel.saveGradient()

        #expect(capture.result != nil)
        if case .saved(let savedScheme) = capture.result {
            #expect(savedScheme.colorMap.stops.count == 3)
            #expect(savedScheme.name == scheme.name)
            #expect(savedScheme.description == scheme.description)

            // Find and verify the edited stops
            let savedFirstStop = savedScheme.colorMap.stops.first { $0.id == firstStop.id }
            #expect(savedFirstStop?.position == 0.15)

            let savedSecondStop = savedScheme.colorMap.stops.first { $0.id == secondStop.id }
            if case .dual = savedSecondStop?.type {
                // Success
            } else {
                Issue.record("Expected second stop to be dual color")
            }
        } else {
            Issue.record("Expected saved result")
        }
    }

    // MARK: - Layout Geometry Integration Tests

    @Test("Integration: Layout geometry calculations with stops")
    func layoutGeometryWithStops() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.red)),
                ColorStop(position: 0.5, type: .single(.green)),
                ColorStop(position: 1.0, type: .single(.blue))
            ])
        )
        let viewModel = GradientEditViewModel(scheme: scheme)

        let geometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: viewModel.zoomLevel,
            panOffset: viewModel.panOffset
        )

        // Verify all stops are visible at default zoom
        for stop in viewModel.colorStops {
            let coord = geometry.viewCoordinate(for: stop.position)
            #expect(coord != nil)
        }

        // Zoom in
        viewModel.updateZoom(2.0)
        let zoomedGeometry = GradientLayoutGeometry(
            viewSize: CGSize(width: 400, height: 800),
            zoomLevel: viewModel.zoomLevel,
            panOffset: viewModel.panOffset
        )

        // Some stops may be outside visible range when zoomed
        let visibleStopCount = viewModel.colorStops.filter { stop in
            zoomedGeometry.viewCoordinate(for: stop.position) != nil
        }.count

        #expect(visibleStopCount >= 1) // At least one stop should be visible
    }
}
