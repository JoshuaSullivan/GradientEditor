import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformView = UIView
typealias PlatformGestureRecognizer = UIGestureRecognizer
#elseif canImport(AppKit)
import AppKit
typealias PlatformView = NSView
typealias PlatformGestureRecognizer = NSGestureRecognizer
#endif

/// A gesture modifier that provides pinch-to-zoom with location information.
///
/// This modifier wraps a platform-specific gesture recognizer (`UIPinchGestureRecognizer` on iOS/visionOS,
/// `NSMagnificationGestureRecognizer` on macOS) to provide both magnification and the location of the
/// pinch/magnification center, enabling zoom behavior similar to mapping apps where the zoom occurs
/// at the gesture center rather than a fixed point.
struct PinchGestureModifier: ViewModifier {
    /// The current magnification scale.
    @Binding var scale: CGFloat

    /// The location of the pinch gesture in the view's coordinate space.
    @Binding var location: CGPoint

    /// Whether a pinch gesture is currently active.
    @Binding var isActive: Bool

    /// Callback invoked when the pinch gesture ends.
    var onEnded: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(
                PinchGestureView(
                    scale: $scale,
                    location: $location,
                    isActive: $isActive,
                    onEnded: onEnded
                )
            )
    }
}

#if canImport(UIKit)
/// A UIViewRepresentable that wraps a UIPinchGestureRecognizer.
private struct PinchGestureView: UIViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var location: CGPoint
    @Binding var isActive: Bool
    var onEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(scale: $scale, location: $location, isActive: $isActive, onEnded: onEnded)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true

        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )
        pinchGesture.delegate = context.coordinator
        view.addGestureRecognizer(pinchGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @Binding var scale: CGFloat
        @Binding var location: CGPoint
        @Binding var isActive: Bool
        var onEnded: () -> Void

        init(scale: Binding<CGFloat>, location: Binding<CGPoint>, isActive: Binding<Bool>, onEnded: @escaping () -> Void) {
            self._scale = scale
            self._location = location
            self._isActive = isActive
            self.onEnded = onEnded
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                isActive = true
                scale = gesture.scale
                location = gesture.location(in: gesture.view)
            case .changed:
                scale = gesture.scale
                location = gesture.location(in: gesture.view)
            case .ended, .cancelled:
                isActive = false
                onEnded()
            default:
                break
            }
        }

        // Allow simultaneous gestures
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}
#elseif canImport(AppKit)
/// An NSViewRepresentable that wraps an NSMagnificationGestureRecognizer.
private struct PinchGestureView: NSViewRepresentable {
    @Binding var scale: CGFloat
    @Binding var location: CGPoint
    @Binding var isActive: Bool
    var onEnded: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(scale: $scale, location: $location, isActive: $isActive, onEnded: onEnded)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear

        let magnifyGesture = NSMagnificationGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleMagnify(_:))
        )
        magnifyGesture.delegate = context.coordinator
        view.addGestureRecognizer(magnifyGesture)

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, NSGestureRecognizerDelegate {
        @Binding var scale: CGFloat
        @Binding var location: CGPoint
        @Binding var isActive: Bool
        var onEnded: () -> Void
        var baseScale: CGFloat = 1.0

        init(scale: Binding<CGFloat>, location: Binding<CGPoint>, isActive: Binding<Bool>, onEnded: @escaping () -> Void) {
            self._scale = scale
            self._location = location
            self._isActive = isActive
            self.onEnded = onEnded
        }

        @MainActor @objc func handleMagnify(_ gesture: NSMagnificationGestureRecognizer) {
            switch gesture.state {
            case .began:
                isActive = true
                baseScale = 1.0
                scale = 1.0 + gesture.magnification
                location = gesture.location(in: gesture.view)
            case .changed:
                scale = 1.0 + gesture.magnification
                location = gesture.location(in: gesture.view)
            case .ended, .cancelled:
                isActive = false
                onEnded()
            default:
                break
            }
        }

        // Allow simultaneous gestures
        func gestureRecognizer(
            _ gestureRecognizer: NSGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: NSGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}
#endif

extension View {
    /// Adds a pinch gesture that provides both scale and location information.
    ///
    /// On iOS and visionOS, this uses `UIPinchGestureRecognizer`. On macOS, this uses
    /// `NSMagnificationGestureRecognizer`. Both provide scale and location information
    /// to enable zoom behavior that centers on the gesture location.
    ///
    /// - Parameters:
    ///   - scale: Binding to the current magnification scale.
    ///   - location: Binding to the gesture location in the view's coordinate space.
    ///   - isActive: Binding indicating whether the gesture is currently active.
    ///   - onEnded: Callback invoked when the gesture ends.
    /// - Returns: A view with the pinch gesture attached.
    func onPinch(
        scale: Binding<CGFloat>,
        location: Binding<CGPoint>,
        isActive: Binding<Bool>,
        onEnded: @escaping () -> Void
    ) -> some View {
        self.modifier(PinchGestureModifier(
            scale: scale,
            location: location,
            isActive: isActive,
            onEnded: onEnded
        ))
    }
}
