import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - SwiftUI Conversions

public extension ColorMap {

    /// Creates a SwiftUI LinearGradient from this color map.
    ///
    /// Converts the color stops in this map to SwiftUI's gradient format, handling both
    /// single-color and dual-color stops. Dual-color stops create hard transitions by
    /// placing both colors at the same position.
    ///
    /// - Parameters:
    ///   - startPoint: The start point of the gradient. Defaults to `.leading`.
    ///   - endPoint: The end point of the gradient. Defaults to `.trailing`.
    /// - Returns: A SwiftUI `LinearGradient` ready to use in views.
    ///
    /// ## Example
    /// ```swift
    /// case .saved(let scheme):
    ///     // Horizontal gradient
    ///     let gradient = scheme.colorMap.linearGradient()
    ///
    ///     // Vertical gradient
    ///     let verticalGradient = scheme.colorMap.linearGradient(
    ///         startPoint: .top,
    ///         endPoint: .bottom
    ///     )
    ///
    ///     // Use in a view
    ///     Rectangle()
    ///         .fill(gradient)
    /// ```
    func linearGradient(
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> LinearGradient {
        let gradStops = stops.flatMap { cStop in
            switch cStop.type {
            case .single(let color):
                return [Gradient.Stop(color: Color(cgColor: color), location: cStop.position)]
            case .dual(let colorA, let colorB):
                return [
                    Gradient.Stop(color: Color(cgColor: colorA), location: cStop.position),
                    Gradient.Stop(color: Color(cgColor: colorB), location: cStop.position)
                ]
            }
        }
        return LinearGradient(stops: gradStops, startPoint: startPoint, endPoint: endPoint)
    }

    /// Creates a SwiftUI RadialGradient from this color map.
    ///
    /// Converts the color stops in this map to a radial gradient emanating from a center point.
    /// The position values (0.0-1.0) map to the gradient's radial extent.
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient. Defaults to `.center`.
    ///   - startRadius: The starting radius. Defaults to `0`.
    ///   - endRadius: The ending radius. Defaults to `200`.
    /// - Returns: A SwiftUI `RadialGradient` ready to use in views.
    ///
    /// ## Example
    /// ```swift
    /// case .saved(let scheme):
    ///     let radial = scheme.colorMap.radialGradient(
    ///         center: .center,
    ///         startRadius: 0,
    ///         endRadius: 300
    ///     )
    ///
    ///     Circle()
    ///         .fill(radial)
    /// ```
    func radialGradient(
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 200
    ) -> RadialGradient {
        let gradStops = stops.flatMap { cStop in
            switch cStop.type {
            case .single(let color):
                return [Gradient.Stop(color: Color(cgColor: color), location: cStop.position)]
            case .dual(let colorA, let colorB):
                return [
                    Gradient.Stop(color: Color(cgColor: colorA), location: cStop.position),
                    Gradient.Stop(color: Color(cgColor: colorB), location: cStop.position)
                ]
            }
        }
        return RadialGradient(
            stops: gradStops,
            center: center,
            startRadius: startRadius,
            endRadius: endRadius
        )
    }

    /// Creates a SwiftUI AngularGradient from this color map.
    ///
    /// Converts the color stops in this map to an angular (conic) gradient rotating around a center point.
    /// The position values (0.0-1.0) map to the full rotation (0° to 360°).
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient. Defaults to `.center`.
    ///   - startAngle: The starting angle. Defaults to `.zero`.
    ///   - endAngle: The ending angle. Defaults to `.degrees(360)`.
    /// - Returns: A SwiftUI `AngularGradient` ready to use in views.
    ///
    /// ## Example
    /// ```swift
    /// case .saved(let scheme):
    ///     let angular = scheme.colorMap.angularGradient(center: .center)
    ///
    ///     Circle()
    ///         .fill(angular)
    /// ```
    func angularGradient(
        center: UnitPoint = .center,
        startAngle: Angle = .zero,
        endAngle: Angle = .degrees(360)
    ) -> AngularGradient {
        let gradStops = stops.flatMap { cStop in
            switch cStop.type {
            case .single(let color):
                return [Gradient.Stop(color: Color(cgColor: color), location: cStop.position)]
            case .dual(let colorA, let colorB):
                return [
                    Gradient.Stop(color: Color(cgColor: colorA), location: cStop.position),
                    Gradient.Stop(color: Color(cgColor: colorB), location: cStop.position)
                ]
            }
        }
        return AngularGradient(
            stops: gradStops,
            center: center,
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// Returns an array of SwiftUI Gradient.Stop values for custom gradient creation.
    ///
    /// Use this when you need direct access to the gradient stops for advanced customization
    /// or when creating custom gradient types.
    ///
    /// - Returns: An array of `Gradient.Stop` values.
    ///
    /// ## Example
    /// ```swift
    /// let stops = colorMap.gradientStops()
    /// let customGradient = LinearGradient(
    ///     stops: stops,
    ///     startPoint: .topLeading,
    ///     endPoint: .bottomTrailing
    /// )
    /// ```
    func gradientStops() -> [Gradient.Stop] {
        stops.flatMap { cStop in
            switch cStop.type {
            case .single(let color):
                return [Gradient.Stop(color: Color(cgColor: color), location: cStop.position)]
            case .dual(let colorA, let colorB):
                return [
                    Gradient.Stop(color: Color(cgColor: colorA), location: cStop.position),
                    Gradient.Stop(color: Color(cgColor: colorB), location: cStop.position)
                ]
            }
        }
    }
}

// MARK: - UIKit Conversions

#if canImport(UIKit) && !os(watchOS)
public extension ColorMap {

    /// Creates a CAGradientLayer configured with this color map.
    ///
    /// Converts the color stops to a Core Animation gradient layer suitable for UIKit views.
    /// Dual-color stops create hard transitions by placing both colors at the same position.
    ///
    /// - Parameters:
    ///   - frame: The frame for the gradient layer. Defaults to `.zero`.
    ///   - type: The gradient type (`.axial` for linear, `.radial`, or `.conic`). Defaults to `.axial`.
    ///   - startPoint: The start point in unit coordinate space. Defaults to `(0, 0)`.
    ///   - endPoint: The end point in unit coordinate space. Defaults to `(1, 0)`.
    /// - Returns: A configured `CAGradientLayer`.
    ///
    /// ## Example
    /// ```swift
    /// case .saved(let scheme):
    ///     // Create gradient layer for UIView
    ///     let gradientLayer = scheme.colorMap.caGradientLayer(
    ///         frame: view.bounds,
    ///         startPoint: CGPoint(x: 0, y: 0),    // top-left
    ///         endPoint: CGPoint(x: 1, y: 1)       // bottom-right
    ///     )
    ///
    ///     // Add to view
    ///     view.layer.insertSublayer(gradientLayer, at: 0)
    ///
    ///     // Radial gradient
    ///     let radial = scheme.colorMap.caGradientLayer(
    ///         frame: view.bounds,
    ///         type: .radial,
    ///         startPoint: CGPoint(x: 0.5, y: 0.5),
    ///         endPoint: CGPoint(x: 1, y: 1)
    ///     )
    /// ```
    func caGradientLayer(
        frame: CGRect = .zero,
        type: CAGradientLayerType = .axial,
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 0)
    ) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = frame
        layer.type = type
        layer.startPoint = startPoint
        layer.endPoint = endPoint

        // Extract colors and locations
        var colors: [CGColor] = []
        var locations: [NSNumber] = []

        for stop in stops {
            switch stop.type {
            case .single(let color):
                colors.append(color)
                locations.append(NSNumber(value: stop.position))
            case .dual(let colorA, let colorB):
                // Both colors at same position for hard transition
                colors.append(colorA)
                locations.append(NSNumber(value: stop.position))
                colors.append(colorB)
                locations.append(NSNumber(value: stop.position))
            }
        }

        layer.colors = colors
        layer.locations = locations

        return layer
    }

    /// Returns the color and location arrays for creating custom CAGradientLayer objects.
    ///
    /// Use this when you need direct access to the color and location arrays for advanced
    /// layer customization.
    ///
    /// - Returns: A tuple containing the CGColor array and NSNumber location array.
    ///
    /// ## Example
    /// ```swift
    /// let (colors, locations) = colorMap.caGradientComponents()
    /// let layer = CAGradientLayer()
    /// layer.colors = colors
    /// layer.locations = locations
    /// layer.type = .radial
    /// // Apply custom configuration...
    /// ```
    func caGradientComponents() -> (colors: [CGColor], locations: [NSNumber]) {
        var colors: [CGColor] = []
        var locations: [NSNumber] = []

        for stop in stops {
            switch stop.type {
            case .single(let color):
                colors.append(color)
                locations.append(NSNumber(value: stop.position))
            case .dual(let colorA, let colorB):
                // Both colors at same position for hard transition
                colors.append(colorA)
                locations.append(NSNumber(value: stop.position))
                colors.append(colorB)
                locations.append(NSNumber(value: stop.position))
            }
        }

        return (colors, locations)
    }
}
#endif

// MARK: - AppKit Conversions

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
public extension ColorMap {

    /// Creates an NSGradient configured with this color map.
    ///
    /// Converts the color stops to an AppKit gradient object. For dual-color stops, this method
    /// approximates hard transitions by placing both colors extremely close together (separated
    /// by 0.0001), creating a sharp visual transition.
    ///
    /// - Returns: A configured `NSGradient`.
    ///
    /// ## Example
    /// ```swift
    /// case .saved(let scheme):
    ///     guard let gradient = scheme.colorMap.nsGradient() else { return }
    ///
    ///     // Draw in NSView
    ///     let startPoint = NSPoint(x: 0, y: bounds.height)
    ///     let endPoint = NSPoint(x: bounds.width, y: bounds.height)
    ///     gradient.draw(from: startPoint, to: endPoint, options: [])
    ///
    ///     // Radial gradient
    ///     let center = NSPoint(x: bounds.midX, y: bounds.midY)
    ///     gradient.draw(
    ///         fromCenter: center,
    ///         radius: 0,
    ///         toCenter: center,
    ///         radius: bounds.width / 2,
    ///         options: []
    ///     )
    /// ```
    func nsGradient() -> NSGradient? {
        var colors: [NSColor] = []
        var locations: [CGFloat] = []

        for stop in stops {
            switch stop.type {
            case .single(let cgColor):
                if let nsColor = NSColor(cgColor: cgColor) {
                    colors.append(nsColor)
                    locations.append(stop.position)
                }
            case .dual(let cgColorA, let cgColorB):
                // Approximate hard transition by placing colors very close together
                if let nsColorA = NSColor(cgColor: cgColorA),
                   let nsColorB = NSColor(cgColor: cgColorB) {
                    colors.append(nsColorA)
                    locations.append(stop.position)
                    colors.append(nsColorB)
                    // Place second color extremely close (0.0001 apart) to approximate hard transition
                    locations.append(min(1.0, stop.position + 0.0001))
                }
            }
        }

        guard !colors.isEmpty else { return nil }

        return NSGradient(colors: colors, atLocations: locations, colorSpace: .deviceRGB)
    }

    /// Returns the color and location arrays for creating custom NSGradient objects.
    ///
    /// Use this when you need direct access to the color and location arrays for advanced
    /// gradient customization.
    ///
    /// - Returns: A tuple containing the color array and location array, or `nil` if no valid colors exist.
    ///
    /// ## Example
    /// ```swift
    /// if let (colors, locations) = colorMap.nsGradientComponents() {
    ///     let gradient = NSGradient(
    ///         colors: colors,
    ///         atLocations: locations,
    ///         colorSpace: .sRGB  // Custom color space
    ///     )
    /// }
    /// ```
    func nsGradientComponents() -> (colors: [NSColor], locations: [CGFloat])? {
        var colors: [NSColor] = []
        var locations: [CGFloat] = []

        for stop in stops {
            switch stop.type {
            case .single(let cgColor):
                if let nsColor = NSColor(cgColor: cgColor) {
                    colors.append(nsColor)
                    locations.append(stop.position)
                }
            case .dual(let cgColorA, let cgColorB):
                if let nsColorA = NSColor(cgColor: cgColorA),
                   let nsColorB = NSColor(cgColor: cgColorB) {
                    colors.append(nsColorA)
                    locations.append(stop.position)
                    colors.append(nsColorB)
                    locations.append(min(1.0, stop.position + 0.0001))
                }
            }
        }

        guard !colors.isEmpty else { return nil }
        return (colors, locations)
    }
}
#endif

// MARK: - Convenience Extensions

public extension GradientColorScheme {

    /// Creates a SwiftUI LinearGradient from this scheme's color map.
    ///
    /// Convenience method that delegates to the color map's `linearGradient()` method.
    ///
    /// - Parameters:
    ///   - startPoint: The start point of the gradient. Defaults to `.leading`.
    ///   - endPoint: The end point of the gradient. Defaults to `.trailing`.
    /// - Returns: A SwiftUI `LinearGradient`.
    ///
    /// ## Example
    /// ```swift
    /// let scheme = GradientColorScheme.wakeIsland
    /// let gradient = scheme.linearGradient(startPoint: .top, endPoint: .bottom)
    ///
    /// Rectangle()
    ///     .fill(gradient)
    /// ```
    func linearGradient(
        startPoint: UnitPoint = .leading,
        endPoint: UnitPoint = .trailing
    ) -> LinearGradient {
        colorMap.linearGradient(startPoint: startPoint, endPoint: endPoint)
    }

    /// Creates a SwiftUI RadialGradient from this scheme's color map.
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient. Defaults to `.center`.
    ///   - startRadius: The starting radius. Defaults to `0`.
    ///   - endRadius: The ending radius. Defaults to `200`.
    /// - Returns: A SwiftUI `RadialGradient`.
    func radialGradient(
        center: UnitPoint = .center,
        startRadius: CGFloat = 0,
        endRadius: CGFloat = 200
    ) -> RadialGradient {
        colorMap.radialGradient(center: center, startRadius: startRadius, endRadius: endRadius)
    }

    /// Creates a SwiftUI AngularGradient from this scheme's color map.
    ///
    /// - Parameters:
    ///   - center: The center point of the gradient. Defaults to `.center`.
    ///   - startAngle: The starting angle. Defaults to `.zero`.
    ///   - endAngle: The ending angle. Defaults to `.degrees(360)`.
    /// - Returns: A SwiftUI `AngularGradient`.
    func angularGradient(
        center: UnitPoint = .center,
        startAngle: Angle = .zero,
        endAngle: Angle = .degrees(360)
    ) -> AngularGradient {
        colorMap.angularGradient(center: center, startAngle: startAngle, endAngle: endAngle)
    }

    #if canImport(UIKit) && !os(watchOS)
    /// Creates a CAGradientLayer from this scheme's color map.
    ///
    /// - Parameters:
    ///   - frame: The frame for the gradient layer. Defaults to `.zero`.
    ///   - type: The gradient type. Defaults to `.axial`.
    ///   - startPoint: The start point in unit coordinate space. Defaults to `(0, 0)`.
    ///   - endPoint: The end point in unit coordinate space. Defaults to `(1, 0)`.
    /// - Returns: A configured `CAGradientLayer`.
    func caGradientLayer(
        frame: CGRect = .zero,
        type: CAGradientLayerType = .axial,
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 0)
    ) -> CAGradientLayer {
        colorMap.caGradientLayer(frame: frame, type: type, startPoint: startPoint, endPoint: endPoint)
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Creates an NSGradient from this scheme's color map.
    ///
    /// - Returns: A configured `NSGradient`, or `nil` if no valid colors exist.
    func nsGradient() -> NSGradient? {
        colorMap.nsGradient()
    }

    /// Returns the color and location arrays for creating custom NSGradient objects.
    ///
    /// - Returns: A tuple containing the color array and location array, or `nil` if no valid colors exist.
    func nsGradientComponents() -> (colors: [NSColor], locations: [CGFloat])? {
        colorMap.nsGradientComponents()
    }
    #endif

    // MARK: - Component Accessors

    /// Returns an array of SwiftUI Gradient.Stop values for custom gradient creation.
    ///
    /// - Returns: An array of `Gradient.Stop` values.
    func gradientStops() -> [Gradient.Stop] {
        colorMap.gradientStops()
    }

    #if canImport(UIKit) && !os(watchOS)
    /// Returns the color and location arrays for creating custom CAGradientLayer objects.
    ///
    /// - Returns: A tuple containing the CGColor array and NSNumber location array.
    func caGradientComponents() -> (colors: [CGColor], locations: [NSNumber]) {
        colorMap.caGradientComponents()
    }
    #endif
}
