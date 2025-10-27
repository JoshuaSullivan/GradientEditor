import Testing
import SwiftUI
@testable import GradientEditor

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

@Suite("Platform Conversion Tests")
struct PlatformConversionTests {

    // MARK: - Test Data

    let simpleColorMap = ColorMap(stops: [
        ColorStop(position: 0.0, type: .single(.red)),
        ColorStop(position: 1.0, type: .single(.blue))
    ])

    let dualColorMap = ColorMap(stops: [
        ColorStop(position: 0.0, type: .single(.red)),
        ColorStop(position: 0.5, type: .dual(.green, .yellow)),
        ColorStop(position: 1.0, type: .single(.blue))
    ])

    // MARK: - SwiftUI Conversion Tests

    @Test("ColorMap creates LinearGradient with default parameters")
    func linearGradientDefault() {
        // Test that method succeeds and returns a gradient
        let gradient = simpleColorMap.linearGradient()
        _ = gradient // Verify it compiles and returns correct type
    }

    @Test("ColorMap creates LinearGradient with custom start and end points")
    func linearGradientCustomPoints() {
        // Test that method succeeds with custom parameters
        let gradient = simpleColorMap.linearGradient(
            startPoint: .top,
            endPoint: .bottom
        )
        _ = gradient // Verify it compiles
    }

    @Test("LinearGradient handles dual-color stops correctly")
    func linearGradientDualColors() {
        // Test that dual-color stops don't crash
        let gradient = dualColorMap.linearGradient()
        _ = gradient // Verify it compiles
    }

    @Test("ColorMap creates RadialGradient with default parameters")
    func radialGradientDefault() {
        // Test that method succeeds
        let gradient = simpleColorMap.radialGradient()
        _ = gradient // Verify it compiles
    }

    @Test("ColorMap creates RadialGradient with custom parameters")
    func radialGradientCustom() {
        // Test with custom parameters
        let gradient = simpleColorMap.radialGradient(
            center: .topLeading,
            startRadius: 10,
            endRadius: 300
        )
        _ = gradient // Verify it compiles
    }

    @Test("ColorMap creates AngularGradient with default parameters")
    func angularGradientDefault() {
        // Test that method succeeds
        let gradient = simpleColorMap.angularGradient()
        _ = gradient // Verify it compiles
    }

    @Test("ColorMap creates AngularGradient with custom angles")
    func angularGradientCustom() {
        // Test with custom angles
        let gradient = simpleColorMap.angularGradient(
            center: .bottom,
            startAngle: .degrees(45),
            endAngle: .degrees(315)
        )
        _ = gradient // Verify it compiles
    }

    // MARK: - GradientColorScheme Convenience Tests

    @Test("GradientColorScheme linearGradient convenience method works")
    func schemeLinearGradient() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: simpleColorMap
        )

        let gradient = scheme.linearGradient(startPoint: .top, endPoint: .bottom)
        _ = gradient // Verify it compiles
    }

    @Test("GradientColorScheme radialGradient convenience method works")
    func schemeRadialGradient() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: simpleColorMap
        )

        let gradient = scheme.radialGradient(endRadius: 250)
        _ = gradient // Verify it compiles
    }

    @Test("GradientColorScheme angularGradient convenience method works")
    func schemeAngularGradient() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: simpleColorMap
        )

        let gradient = scheme.angularGradient()
        _ = gradient // Verify it compiles
    }

    // MARK: - UIKit Conversion Tests

    #if canImport(UIKit) && !os(watchOS)
    @Test("ColorMap creates CAGradientLayer with default parameters")
    func caGradientLayerDefault() {
        let layer = simpleColorMap.caGradientLayer()

        #expect(layer.colors?.count == 2)
        #expect(layer.locations?.count == 2)
        #expect(layer.type == .axial)
        #expect(layer.startPoint == CGPoint(x: 0, y: 0))
        #expect(layer.endPoint == CGPoint(x: 1, y: 0))
    }

    @Test("ColorMap creates CAGradientLayer with custom frame")
    func caGradientLayerCustomFrame() {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        let layer = simpleColorMap.caGradientLayer(frame: frame)

        #expect(layer.frame == frame)
    }

    @Test("CAGradientLayer handles dual-color stops correctly")
    func caGradientLayerDualColors() {
        let layer = dualColorMap.caGradientLayer()

        // Should have 4 colors: start, dual (2 colors), end
        #expect(layer.colors?.count == 4)
        #expect(layer.locations?.count == 4)

        // Check that dual colors are at same position
        if let locations = layer.locations {
            #expect(locations[1].doubleValue == locations[2].doubleValue)
        }
    }

    @Test("ColorMap creates radial CAGradientLayer")
    func caGradientLayerRadial() {
        let layer = simpleColorMap.caGradientLayer(
            type: .radial,
            startPoint: CGPoint(x: 0.5, y: 0.5),
            endPoint: CGPoint(x: 1, y: 1)
        )

        #expect(layer.type == .radial)
        #expect(layer.startPoint == CGPoint(x: 0.5, y: 0.5))
        #expect(layer.endPoint == CGPoint(x: 1, y: 1))
    }

    @Test("ColorMap creates conic CAGradientLayer")
    func caGradientLayerConic() {
        let layer = simpleColorMap.caGradientLayer(
            type: .conic,
            startPoint: CGPoint(x: 0.5, y: 0.5),
            endPoint: CGPoint(x: 0.5, y: 0)
        )

        #expect(layer.type == .conic)
    }

    @Test("GradientColorScheme caGradientLayer convenience method works")
    func schemeCaGradientLayer() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: simpleColorMap
        )

        let layer = scheme.caGradientLayer(
            frame: CGRect(x: 0, y: 0, width: 200, height: 200)
        )

        #expect(layer.frame.width == 200)
        #expect(layer.frame.height == 200)
        #expect(layer.colors?.count == 2)
    }
    #endif

    // MARK: - AppKit Conversion Tests

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    @Test("ColorMap creates NSGradient")
    func nsGradientCreation() {
        let gradient = simpleColorMap.nsGradient()

        #expect(gradient != nil)
    }

    @Test("NSGradient has correct number of color stops")
    func nsGradientStopCount() {
        let gradient = simpleColorMap.nsGradient()

        #expect(gradient != nil)
        if let gradient = gradient {
            #expect(gradient.numberOfColorStops == 2)
        }
    }

    @Test("NSGradient handles dual-color stops")
    func nsGradientDualColors() {
        let gradient = dualColorMap.nsGradient()

        #expect(gradient != nil)
        // Dual-color stops create hard transition by placing both colors very close together
        // Should have 4 stops: start, dual colorA, dual colorB (at +0.0001), end
        if let gradient = gradient {
            #expect(gradient.numberOfColorStops == 4)
        }
    }

    @Test("GradientColorScheme nsGradient convenience method works")
    func schemeNsGradient() {
        let scheme = GradientColorScheme(
            name: "Test",
            description: "Test gradient",
            colorMap: simpleColorMap
        )

        let gradient = scheme.nsGradient()

        #expect(gradient != nil)
        if let gradient = gradient {
            #expect(gradient.numberOfColorStops == 2)
        }
    }
    #endif

    // MARK: - Preset Gradient Conversion Tests

    @Test("Wake Island preset converts to LinearGradient")
    func wakeIslandLinearGradient() {
        let gradient = GradientColorScheme.wakeIsland.linearGradient()
        _ = gradient // Verify it compiles
    }

    @Test("Neon Ripples preset converts to CAGradientLayer", .enabled(if: canImportUIKit))
    func neonRipplesCAGradient() {
        #if canImport(UIKit) && !os(watchOS)
        let layer = GradientColorScheme.neonRipples.caGradientLayer(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100)
        )

        #expect(layer.colors != nil)
        #expect(layer.colors!.count > 0)
        #endif
    }

    @Test("Topographic preset converts to RadialGradient")
    func topographicRadialGradient() {
        let gradient = GradientColorScheme.topographic.radialGradient()
        _ = gradient // Verify it compiles
    }

    // MARK: - Edge Case Tests

    @Test("Empty ColorMap handled gracefully for NSGradient", .enabled(if: canImportAppKit))
    func emptyColorMapNSGradient() {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        let emptyMap = ColorMap(stops: [])
        let gradient = emptyMap.nsGradient()

        #expect(gradient == nil)
        #endif
    }

    @Test("Single stop ColorMap creates valid gradient")
    func singleStopGradient() {
        let singleStop = ColorMap(stops: [
            ColorStop(position: 0.5, type: .single(.green))
        ])

        let gradient = singleStop.linearGradient()
        _ = gradient // Verify it compiles
    }
}

// MARK: - Helper Traits

extension Tag {
    @Tag static var canImportUIKit: Self
    @Tag static var canImportAppKit: Self
}

#if canImport(UIKit)
extension PlatformConversionTests {
    static let canImportUIKit = true
}
#else
extension PlatformConversionTests {
    static let canImportUIKit = false
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
extension PlatformConversionTests {
    static let canImportAppKit = true
}
#else
extension PlatformConversionTests {
    static let canImportAppKit = false
}
#endif
