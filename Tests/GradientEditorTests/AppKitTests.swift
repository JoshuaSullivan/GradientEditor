#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import Testing
import AppKit
import SwiftUI
@testable import GradientEditor

@Suite("AppKit Tests")
@MainActor
struct AppKitTests {

    // MARK: - GradientEditorViewController Initialization Tests

    @Test("GradientEditorViewController initializes with completion handler")
    func viewControllerInitWithCompletion() {
        let resultState = ResultState()
        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            Task { @MainActor in
                resultState.result = result
            }
        }

        // Load view to set title
        _ = vc.view

        #expect(vc.title == GradientColorScheme.wakeIsland.name)
        #expect(resultState.result == nil) // Should not be called yet
    }

    @Test("GradientEditorViewController initializes without completion handler")
    func viewControllerInitWithoutCompletion() {
        let vc = GradientEditorViewController(scheme: .neonRipples)

        // Load view to set title
        _ = vc.view

        #expect(vc.title == GradientColorScheme.neonRipples.name)
    }

    @Test("GradientEditorViewController initializes with custom scheme")
    func viewControllerInitWithCustomScheme() {
        let stops = [
            ColorStop(position: 0.0, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1))),
            ColorStop(position: 1.0, type: .single(CGColor(red: 0, green: 0, blue: 1, alpha: 1)))
        ]
        let customScheme = GradientColorScheme(
            name: "Custom Test",
            description: "A custom gradient for testing",
            colorMap: ColorMap(stops: stops)
        )

        let vc = GradientEditorViewController(scheme: customScheme)

        // Load view to set title
        _ = vc.view

        #expect(vc.title == "Custom Test")
    }

    // MARK: - Lifecycle Tests

    @Test("GradientEditorViewController loadView sets up hosting controller")
    func viewControllerLoadView() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)

        // Load the view
        _ = vc.view

        // Verify view hierarchy is set up
        #expect(vc.children.count == 1)
        #expect(vc.children.first is NSHostingController<GradientEditView>)
    }

    @Test("GradientEditorViewController creates cancel and save buttons")
    func viewControllerCreatesButtons() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)

        // Load the view to trigger button creation
        _ = vc.view

        // Verify buttons exist in view hierarchy
        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        #expect(buttons.count >= 2) // Should have at least cancel and save buttons
    }

    // MARK: - Completion Handler Tests

    @Test("GradientEditorViewController calls completion on save")
    func viewControllerSaveCompletion() async {
        let resultState = ResultState()
        let expectation = Expectation()

        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            Task { @MainActor in
                resultState.result = result
                expectation.fulfill()
            }
        }

        // Load the view to ensure setup is complete
        _ = vc.view

        // Find and click save button
        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let saveButton = buttons.first { $0.title == "Save" }
        #expect(saveButton != nil)

        // Simulate save action
        saveButton?.performClick(nil)

        await expectation.fulfillment()

        #expect(resultState.result != nil)
        if case .saved(let scheme) = resultState.result {
            #expect(scheme.name == GradientColorScheme.wakeIsland.name)
        } else {
            Issue.record("Expected saved result")
        }
    }

    @Test("GradientEditorViewController calls completion on cancel")
    func viewControllerCancelCompletion() async {
        let resultState = ResultState()
        let expectation = Expectation()

        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            Task { @MainActor in
                resultState.result = result
                expectation.fulfill()
            }
        }

        // Load the view to ensure setup is complete
        _ = vc.view

        // Find and click cancel button
        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let cancelButton = buttons.first { $0.title == "Cancel" }
        #expect(cancelButton != nil)

        // Simulate cancel action
        cancelButton?.performClick(nil)

        await expectation.fulfillment()

        #expect(resultState.result != nil)
        if case .cancelled = resultState.result {
            // Success
        } else {
            Issue.record("Expected cancelled result")
        }
    }

    // MARK: - Delegate Tests

    @Test("GradientEditorViewController calls delegate on save")
    func viewControllerDelegateSave() async {
        let delegate = MockDelegate()
        let expectation = Expectation()
        delegate.onSave = { _, _ in
            expectation.fulfill()
        }

        let vc = GradientEditorViewController(scheme: .wakeIsland)
        vc.delegate = delegate

        // Load the view
        _ = vc.view

        // Find and click save button
        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let saveButton = buttons.first { $0.title == "Save" }
        saveButton?.performClick(nil)

        await expectation.fulfillment()

        #expect(delegate.savedScheme != nil)
        #expect(delegate.savedScheme?.name == GradientColorScheme.wakeIsland.name)
        #expect(delegate.didCancel == false)
    }

    @Test("GradientEditorViewController calls delegate on cancel")
    func viewControllerDelegateCancel() async {
        let delegate = MockDelegate()
        let expectation = Expectation()
        delegate.onCancel = { _ in
            expectation.fulfill()
        }

        let vc = GradientEditorViewController(scheme: .wakeIsland)
        vc.delegate = delegate

        // Load the view
        _ = vc.view

        // Find and click cancel button
        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let cancelButton = buttons.first { $0.title == "Cancel" }
        cancelButton?.performClick(nil)

        await expectation.fulfillment()

        #expect(delegate.didCancel == true)
        #expect(delegate.savedScheme == nil)
    }

    @Test("GradientEditorViewController calls both delegate and completion")
    func viewControllerBothCallbackPatterns() async {
        let completionState = CompletionState()
        let delegate = MockDelegate()
        let expectation = Expectation()
        expectation.expectedFulfillmentCount = 2

        delegate.onSave = { _, _ in
            Task { @MainActor in
                expectation.fulfill()
            }
        }

        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            Task { @MainActor in
                completionState.called = true
                expectation.fulfill()
            }
        }
        vc.delegate = delegate

        // Load the view
        _ = vc.view

        // Find and click save button
        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let saveButton = buttons.first { $0.title == "Save" }
        saveButton?.performClick(nil)

        await expectation.fulfillment()

        #expect(completionState.called == true)
        #expect(delegate.savedScheme != nil)
    }

    // MARK: - Button Tests

    @Test("GradientEditorViewController has cancel button with escape key")
    func viewControllerCancelButtonKeyEquivalent() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)
        _ = vc.view

        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let cancelButton = buttons.first { $0.title == "Cancel" }

        #expect(cancelButton != nil)
        #expect(cancelButton?.keyEquivalent == "\u{1b}") // Escape key
    }

    @Test("GradientEditorViewController has save button with return key")
    func viewControllerSaveButtonKeyEquivalent() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)
        _ = vc.view

        let buttons = vc.view.subviews.flatMap { $0.subviews }.compactMap { $0 as? NSButton }
        let saveButton = buttons.first { $0.title == "Save" }

        #expect(saveButton != nil)
        #expect(saveButton?.keyEquivalent == "\r") // Return key
    }

    @Test("GradientEditorViewController title matches scheme name")
    func viewControllerTitleMatchesScheme() {
        let schemes: [GradientColorScheme] = [.wakeIsland, .neonRipples, .topographic]

        for scheme in schemes {
            let vc = GradientEditorViewController(scheme: scheme)
            _ = vc.view // Load view to set title
            #expect(vc.title == scheme.name)
        }
    }

    // MARK: - View Size Tests

    @Test("GradientEditorViewController has reasonable default size")
    func viewControllerDefaultSize() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)
        _ = vc.view

        let viewSize = vc.view.frame.size
        #expect(viewSize.width > 0)
        #expect(viewSize.height > 0)
    }
}

// MARK: - Mock Delegate

@MainActor
class MockDelegate: GradientEditorDelegate {
    var savedScheme: GradientColorScheme?
    var didCancel = false
    var onSave: ((GradientEditorViewController, GradientColorScheme) -> Void)?
    var onCancel: ((GradientEditorViewController) -> Void)?

    func gradientEditor(_ editor: GradientEditorViewController, didSaveScheme scheme: GradientColorScheme) {
        savedScheme = scheme
        onSave?(editor, scheme)
    }

    func gradientEditorDidCancel(_ editor: GradientEditorViewController) {
        didCancel = true
        onCancel?(editor)
    }
}

// MARK: - Expectation Helper

@MainActor
class Expectation {
    private var fulfilled = false
    private var fulfillmentCount = 0
    var expectedFulfillmentCount = 1

    func fulfill() {
        fulfillmentCount += 1
        if fulfillmentCount >= expectedFulfillmentCount {
            fulfilled = true
        }
    }

    func fulfillment() async {
        while !fulfilled {
            try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        }
    }
}

// MARK: - Completion State Helper

@MainActor
class CompletionState {
    var called = false
}

// MARK: - Result State Helper

@MainActor
class ResultState {
    var result: GradientEditorResult?
}
#endif
