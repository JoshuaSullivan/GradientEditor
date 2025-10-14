import Testing
import Foundation
import CoreGraphics
import Combine
@testable import GradientEditor

@Suite("ColorStopEditorViewModel Tests")
@MainActor
struct ColorStopEditorViewModelTests {

    // MARK: - Test Helper

    final class ActionCapture: @unchecked Sendable {
        var actions: [ColorStopEditorViewModel.Action] = []
        var cancellables = Set<AnyCancellable>()
    }

    // MARK: - Initialization Tests

    @Test("ViewModel initializes with single color stop")
    func initializationSingleColor() {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        #expect(viewModel.position == 0.5)
        #expect(viewModel.isSingleColorStop == true)
        #expect(viewModel.firstcolor == .red)
    }

    @Test("ViewModel initializes with dual color stop")
    func initializationDualColor() {
        let stop = ColorStop(position: 0.3, type: .dual(.blue, .green))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        #expect(viewModel.position == 0.3)
        #expect(viewModel.isSingleColorStop == false)
        #expect(viewModel.firstcolor == .blue)
        #expect(viewModel.secondColor == .green)
    }

    @Test("ViewModel initializes with canDelete true by default")
    func canDeleteDefault() {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        #expect(viewModel.canDelete == true)
    }

    // MARK: - Position Clamping Tests

    @Test("Position clamps to minimum value")
    func positionClampMin() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        viewModel.position = -0.5
        #expect(viewModel.position == 0.0)
    }

    @Test("Position clamps to maximum value")
    func positionClampMax() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        viewModel.position = 1.5
        #expect(viewModel.position == 1.0)
    }

    @Test("Position accepts valid values")
    func positionValidValues() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)

        viewModel.position = 0.0
        #expect(viewModel.position == 0.0)

        viewModel.position = 0.75
        #expect(viewModel.position == 0.75)

        viewModel.position = 1.0
        #expect(viewModel.position == 1.0)
    }

    // MARK: - Action Publisher Tests

    @Test("Changing position publishes updatedStop action")
    func positionChangePublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.position = 0.75

        // Wait a moment for the publisher to emit
        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.count == 1)
        if case .updatedStop(let updatedStop) = capture.actions.first {
            #expect(updatedStop.position == 0.75)
        } else {
            Issue.record("Expected updatedStop action")
        }
    }

    @Test("Changing firstcolor publishes updatedStop action")
    func firstColorChangePublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.firstcolor = .blue

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.count == 1)
        if case .updatedStop(let updatedStop) = capture.actions.first {
            #expect(updatedStop.type.startColor == .blue)
        } else {
            Issue.record("Expected updatedStop action")
        }
    }

    @Test("Changing isSingleColorStop publishes updatedStop action")
    func colorTypeChangePublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.isSingleColorStop = false

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.count == 1)
        if case .updatedStop(let updatedStop) = capture.actions.first {
            if case .dual = updatedStop.type {
                // Success
            } else {
                Issue.record("Expected dual color type")
            }
        } else {
            Issue.record("Expected updatedStop action")
        }
    }

    @Test("Multiple property changes publish multiple actions")
    func multipleChangesPublish() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.position = 0.75
        viewModel.firstcolor = .blue
        viewModel.isSingleColorStop = false

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.count == 3)
        for action in capture.actions {
            if case .updatedStop = action {
                // Expected
            } else {
                Issue.record("Expected all actions to be updatedStop")
            }
        }
    }

    // MARK: - Button Action Tests

    @Test("prevTapped publishes prev action")
    func prevTappedPublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.prevTapped()

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.last != nil)
        if case .prev = capture.actions.last {
            // Success
        } else {
            Issue.record("Expected prev action")
        }
    }

    @Test("nextTapped publishes next action")
    func nextTappedPublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.nextTapped()

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.last != nil)
        if case .next = capture.actions.last {
            // Success
        } else {
            Issue.record("Expected next action")
        }
    }

    @Test("closeTapped publishes close action")
    func closeTappedPublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.closeTapped()

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.last != nil)
        if case .close = capture.actions.last {
            // Success
        } else {
            Issue.record("Expected close action")
        }
    }

    @Test("deleteTapped publishes delete action")
    func deleteTappedPublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.deleteTapped()

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.last != nil)
        if case .delete = capture.actions.last {
            // Success
        } else {
            Issue.record("Expected delete action")
        }
    }

    @Test("duplicateTapped publishes duplicate action")
    func duplicateTappedPublishes() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.duplicateTapped()

        try? await Task.sleep(for: .milliseconds(10))

        #expect(capture.actions.last != nil)
        if case .duplicate = capture.actions.last {
            // Success
        } else {
            Issue.record("Expected duplicate action")
        }
    }

    // MARK: - change(colorStop:) Tests

    @Test("change updates to new single color stop")
    func changeToSingleColorStop() {
        let initialStop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: initialStop)

        let newStop = ColorStop(position: 0.75, type: .single(.blue))
        viewModel.change(colorStop: newStop)

        #expect(viewModel.position == 0.75)
        #expect(viewModel.isSingleColorStop == true)
        #expect(viewModel.firstcolor == .blue)
    }

    @Test("change updates to new dual color stop")
    func changeToDualColorStop() {
        let initialStop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: initialStop)

        let newStop = ColorStop(position: 0.25, type: .dual(.green, .yellow))
        viewModel.change(colorStop: newStop)

        #expect(viewModel.position == 0.25)
        #expect(viewModel.isSingleColorStop == false)
        #expect(viewModel.firstcolor == .green)
        #expect(viewModel.secondColor == .yellow)
    }

    @Test("change from single to dual color stop")
    func changeFromSingleToDual() {
        let initialStop = ColorStop(position: 0.5, type: .single(.red))
        let viewModel = ColorStopEditorViewModel(colorStop: initialStop)

        #expect(viewModel.isSingleColorStop == true)

        let newStop = ColorStop(position: 0.75, type: .dual(.blue, .green))
        viewModel.change(colorStop: newStop)

        #expect(viewModel.isSingleColorStop == false)
        #expect(viewModel.firstcolor == .blue)
        #expect(viewModel.secondColor == .green)
    }

    @Test("change from dual to single color stop")
    func changeFromDualToSingle() {
        let initialStop = ColorStop(position: 0.5, type: .dual(.blue, .green))
        let viewModel = ColorStopEditorViewModel(colorStop: initialStop)

        #expect(viewModel.isSingleColorStop == false)

        let newStop = ColorStop(position: 0.75, type: .single(.red))
        viewModel.change(colorStop: newStop)

        #expect(viewModel.isSingleColorStop == true)
        #expect(viewModel.firstcolor == .red)
    }

    // MARK: - Edge Case Tests

    @Test("Updated stop preserves ID through property changes")
    func updatedStopPreservesId() async {
        let stop = ColorStop(position: 0.5, type: .single(.red))
        let stopId = stop.id
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        viewModel.position = 0.75

        try? await Task.sleep(for: .milliseconds(10))

        if case .updatedStop(let updatedStop) = capture.actions.first {
            #expect(updatedStop.id == stopId)
        } else {
            Issue.record("Expected updatedStop action")
        }
    }

    @Test("Dual color stop uses both colors correctly")
    func dualColorStopCorrectly() async {
        let stop = ColorStop(position: 0.5, type: .dual(.red, .blue))
        let viewModel = ColorStopEditorViewModel(colorStop: stop)
        let capture = ActionCapture()

        viewModel.actionPublisher.sink { action in
            capture.actions.append(action)
        }.store(in: &capture.cancellables)

        // Trigger an update
        viewModel.position = 0.6

        try? await Task.sleep(for: .milliseconds(10))

        if case .updatedStop(let updatedStop) = capture.actions.first {
            #expect(updatedStop.type.startColor == .red)
            #expect(updatedStop.type.endColor == .blue)
        } else {
            Issue.record("Expected updatedStop action")
        }
    }
}
