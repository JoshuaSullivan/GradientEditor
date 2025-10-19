#if canImport(UIKit)
import Testing
import UIKit
@testable import GradientEditor

@Suite("UIKit Tests")
@MainActor
struct UIKitTests {

    // MARK: - GradientEditorViewController Initialization Tests

    @Test("GradientEditorViewController initializes with completion handler")
    func viewControllerInitWithCompletion() {
        var receivedResult: GradientEditorResult?
        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            receivedResult = result
        }

        #expect(vc.title == GradientColorScheme.wakeIsland.name)
        #expect(vc.navigationItem.leftBarButtonItem != nil)
        #expect(vc.navigationItem.rightBarButtonItem != nil)
        #expect(receivedResult == nil) // Should not be called yet
    }

    @Test("GradientEditorViewController initializes without completion handler")
    func viewControllerInitWithoutCompletion() {
        let vc = GradientEditorViewController(scheme: .neonRipples)

        #expect(vc.title == GradientColorScheme.neonRipples.name)
        #expect(vc.navigationItem.leftBarButtonItem != nil)
        #expect(vc.navigationItem.rightBarButtonItem != nil)
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

        #expect(vc.title == "Custom Test")
        #expect(vc.navigationItem.leftBarButtonItem != nil)
        #expect(vc.navigationItem.rightBarButtonItem != nil)
    }

    // MARK: - Lifecycle Tests

    @Test("GradientEditorViewController viewDidLoad sets up hosting controller")
    func viewControllerViewDidLoad() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)

        // Load the view
        _ = vc.view

        // Verify view hierarchy is set up
        #expect(vc.children.count == 1)
        #expect(vc.children.first is UIHostingController<GradientEditView>)
    }

    // MARK: - Completion Handler Tests

    @Test("GradientEditorViewController calls completion on save")
    func viewControllerSaveCompletion() async {
        var receivedResult: GradientEditorResult?
        let expectation = Expectation()

        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            receivedResult = result
            expectation.fulfill()
        }

        // Load the view to ensure setup is complete
        _ = vc.view

        // Simulate save tap
        vc.navigationItem.rightBarButtonItem?.target?.perform(
            vc.navigationItem.rightBarButtonItem!.action!,
            with: vc.navigationItem.rightBarButtonItem
        )

        await expectation.fulfillment()

        #expect(receivedResult != nil)
        if case .saved(let scheme) = receivedResult {
            #expect(scheme.name == GradientColorScheme.wakeIsland.name)
        } else {
            Issue.record("Expected saved result")
        }
    }

    @Test("GradientEditorViewController calls completion on cancel")
    func viewControllerCancelCompletion() async {
        var receivedResult: GradientEditorResult?
        let expectation = Expectation()

        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            receivedResult = result
            expectation.fulfill()
        }

        // Load the view to ensure setup is complete
        _ = vc.view

        // Simulate cancel tap
        vc.navigationItem.leftBarButtonItem?.target?.perform(
            vc.navigationItem.leftBarButtonItem!.action!,
            with: vc.navigationItem.leftBarButtonItem
        )

        await expectation.fulfillment()

        #expect(receivedResult != nil)
        if case .cancelled = receivedResult {
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

        // Simulate save tap
        vc.navigationItem.rightBarButtonItem?.target?.perform(
            vc.navigationItem.rightBarButtonItem!.action!,
            with: vc.navigationItem.rightBarButtonItem
        )

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

        // Simulate cancel tap
        vc.navigationItem.leftBarButtonItem?.target?.perform(
            vc.navigationItem.leftBarButtonItem!.action!,
            with: vc.navigationItem.leftBarButtonItem
        )

        await expectation.fulfillment()

        #expect(delegate.didCancel == true)
        #expect(delegate.savedScheme == nil)
    }

    @Test("GradientEditorViewController calls both delegate and completion")
    func viewControllerBothCallbackPatterns() async {
        var completionCalled = false
        let delegate = MockDelegate()
        let expectation = Expectation()
        expectation.expectedFulfillmentCount = 2

        delegate.onSave = { _, _ in
            expectation.fulfill()
        }

        let vc = GradientEditorViewController(scheme: .wakeIsland) { result in
            completionCalled = true
            expectation.fulfill()
        }
        vc.delegate = delegate

        // Load the view
        _ = vc.view

        // Simulate save tap
        vc.navigationItem.rightBarButtonItem?.target?.perform(
            vc.navigationItem.rightBarButtonItem!.action!,
            with: vc.navigationItem.rightBarButtonItem
        )

        await expectation.fulfillment()

        #expect(completionCalled == true)
        #expect(delegate.savedScheme != nil)
    }

    // MARK: - Navigation Bar Tests

    @Test("GradientEditorViewController has cancel button")
    func viewControllerHasCancelButton() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)

        #expect(vc.navigationItem.leftBarButtonItem != nil)
        #expect(vc.navigationItem.leftBarButtonItem?.systemItem == .cancel)
    }

    @Test("GradientEditorViewController has save button")
    func viewControllerHasSaveButton() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)

        #expect(vc.navigationItem.rightBarButtonItem != nil)
        #expect(vc.navigationItem.rightBarButtonItem?.systemItem == .save)
    }

    @Test("GradientEditorViewController title matches scheme name")
    func viewControllerTitleMatchesScheme() {
        let schemes: [GradientColorScheme] = [.wakeIsland, .neonRipples, .topographic]

        for scheme in schemes {
            let vc = GradientEditorViewController(scheme: scheme)
            #expect(vc.title == scheme.name)
        }
    }

    // MARK: - Presentation Helper Tests

    @Test("GradientEditorViewController presentModally wraps in navigation controller")
    func viewControllerPresentModallyHelper() async {
        let vc = GradientEditorViewController(scheme: .wakeIsland)
        let presentingVC = UIViewController()

        // Create a window to make the presenting VC part of the hierarchy
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        window.rootViewController = presentingVC
        window.makeKeyAndVisible()

        let expectation = Expectation()

        vc.presentModally(from: presentingVC, animated: false) {
            expectation.fulfill()
        }

        await expectation.fulfillment()

        // Verify navigation controller was created
        #expect(presentingVC.presentedViewController is UINavigationController)
        if let nav = presentingVC.presentedViewController as? UINavigationController {
            #expect(nav.topViewController === vc)
        }

        // Clean up
        await presentingVC.dismiss(animated: false)
    }

    @Test("GradientEditorViewController pushOnto adds to navigation stack")
    func viewControllerPushOntoHelper() {
        let vc = GradientEditorViewController(scheme: .wakeIsland)
        let navController = UINavigationController()

        vc.pushOnto(navigationController: navController, animated: false)

        #expect(navController.viewControllers.count == 1)
        #expect(navController.topViewController === vc)
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
#endif
