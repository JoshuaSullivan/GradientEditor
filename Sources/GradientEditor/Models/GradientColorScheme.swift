import CoreImage
import SwiftUI

/// A named collection of gradient colors.
///
/// `GradientColorScheme` represents a complete gradient definition with metadata like name and description.
/// It contains a ``ColorMap`` which defines the actual gradient stops and colors.
///
/// ## Topics
///
/// ### Creating a Scheme
/// - ``init(id:name:description:colorMap:)``
///
/// ### Preset Schemes
/// - ``allPresets``
/// - ``blackAndWhite``
/// - ``wakeIsland``
/// - ``neonRipples``
/// - ``appleTwoRiver``
/// - ``electoralMap``
/// - ``topographic``
///
/// ### Encoding and Decoding
/// - ``toJSON()``
/// - ``from(json:)``
///
/// ### Properties
/// - ``id``
/// - ``name``
/// - ``description``
/// - ``colorMap``
public struct GradientColorScheme: Identifiable, Equatable, Codable, Hashable, Comparable, Sendable {

    /// The unique identifier for this scheme.
    public let id: UUID

    /// The human-readable name of the color scheme.
    ///
    /// This name is typically displayed in UI elements like lists or pickers.
    public let name: String

    /// A detailed description of the color scheme.
    ///
    /// Describes the inspiration, theme, or purpose of the color scheme.
    public let description: String

    /// The color map defining the gradient stops.
    ///
    /// Contains all color stops that make up the gradient, including their positions and colors.
    public let colorMap: ColorMap

    /// Creates a new gradient color scheme.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID if not provided.
    ///   - name: The display name for the scheme.
    ///   - description: A description of the scheme's theme or purpose.
    ///   - colorMap: The color map containing gradient stops.
    ///
    /// ## Example
    /// ```swift
    /// let customScheme = GradientColorScheme(
    ///     name: "Ocean Depths",
    ///     description: "Deep blues fading to black",
    ///     colorMap: ColorMap(stops: [
    ///         ColorStop(position: 0.0, type: .single(.blue)),
    ///         ColorStop(position: 1.0, type: .single(.black))
    ///     ])
    /// )
    /// ```
    public init(id: UUID = UUID(), name: String, description: String, colorMap: ColorMap) {
        self.id = id
        self.name = name
        self.description = description
        self.colorMap = colorMap
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func < (lhs: GradientColorScheme, rhs: GradientColorScheme) -> Bool {
        return lhs.name < rhs.name
    }
}

// MARK: - Presets

public extension GradientColorScheme {

    /// All available preset gradient schemes.
    ///
    /// Returns an array containing all built-in gradient presets, useful for displaying
    /// in pickers or galleries.
    static var allPresets: [GradientColorScheme] {
        [blackAndWhite, wakeIsland, neonRipples, appleTwoRiver, electoralMap, topographic]
    }

    /// A simple black-to-white gradient.
    ///
    /// Useful as input for filter effects or as a neutral gradient base.
    static let blackAndWhite = GradientColorScheme(
        name: "Black & White",
        description: "A simple, black-and-white color scheme that is good for input into filter effects.",
        colorMap: .blackAndWhite
    )

    /// A tropical island-inspired gradient.
    ///
    /// Colors sampled from photos of Wake Island, transitioning from deep ocean blues
    /// to sandy beaches and lush greens.
    static let wakeIsland = GradientColorScheme(
        name: "Wake Island",
        description: "A tropical island color scheme sampled from photos of Wake Island.",
        colorMap: .wakeIsland
    )

    /// An abstract neon-themed gradient.
    ///
    /// Features sharp cyan lines against black, creating a snaking neon effect.
    static let neonRipples = GradientColorScheme(
        name: "Neon Ripples",
        description: "An abstract color set of snaking lines.",
        colorMap: .neonRipples
    )

    /// A retro computing-inspired gradient.
    ///
    /// Inspired by the iconic green CRT monitor of the Apple ][ computer.
    static let appleTwoRiver = GradientColorScheme(
        name: "Apple ][ River",
        description: "Inspired by the green CRT monitor that came with the Apple ][ computer.",
        colorMap: .appleTwoRiver
    )

    /// A political map-themed gradient.
    ///
    /// Features the classic red and blue colors associated with electoral maps.
    static let electoralMap = GradientColorScheme(
        name: "Electoral Map",
        description: "Red vs. Blue",
        colorMap: .electoralMap
    )

    /// A topographic map-inspired gradient.
    ///
    /// Alternating green and brown bands that resemble elevation contours on a map.
    static let topographic = GradientColorScheme(
        name: "Topographic",
        description: "Resembles a topographic map.",
        colorMap: .topographic
    )

    // MARK: - Encoding and Decoding

    /// Encodes this gradient scheme to pretty-printed JSON data.
    ///
    /// - Returns: JSON data representation with formatting for readability.
    /// - Throws: An error if encoding fails.
    ///
    /// ## Example
    /// ```swift
    /// let scheme = GradientColorScheme.wakeIsland
    /// let jsonData = try scheme.toJSON()
    /// let jsonString = String(data: jsonData, encoding: .utf8)
    /// ```
    func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }

    /// Creates a gradient scheme from JSON data.
    ///
    /// - Parameter data: JSON data to decode.
    /// - Returns: A decoded gradient color scheme.
    /// - Throws: An error if decoding fails.
    ///
    /// ## Example
    /// ```swift
    /// let jsonData = """
    /// {
    ///   "id": "...",
    ///   "name": "Custom Gradient",
    ///   "description": "My custom gradient",
    ///   "colorMap": { ... }
    /// }
    /// """.data(using: .utf8)!
    /// let scheme = try GradientColorScheme.from(json: jsonData)
    /// ```
    static func from(json data: Data) throws -> GradientColorScheme {
        let decoder = JSONDecoder()
        return try decoder.decode(GradientColorScheme.self, from: data)
    }
}

 public extension ColorMap {
     static let blackAndWhite = ColorMap(stops: [
         ColorStop(position: 0.0, type: .single(.black)),
         ColorStop(position: 1.0, type: .single(.white))
     ])
    
    
     static let wakeIsland = ColorMap(stops:[
         ColorStop(position: 0.20, type: .single(.make(redInt: 9, green: 33, blue: 79))),
         ColorStop(position: 0.40, type: .single(.make(redInt: 15, green: 48, blue: 88))),
         ColorStop(position: 0.50, type: .single(.make(redInt: 45, green: 110, blue: 148))),
         ColorStop(position: 0.52, type: .dual(.make(redInt: 224, green: 240, blue: 251),
                                          .make(redInt: 176, green: 151, blue: 132))),
         ColorStop(position: 0.70, type: .dual(.make(redInt: 230, green: 203, blue: 185),
                                          .make(redInt: 66, green: 82, blue: 68))),
         ColorStop(position: 0.85, type: .single(.make(redInt: 64, green: 70, blue: 64))),
         ColorStop(position: 1.00, type: .single(.make(redInt: 98, green: 101, blue: 89)))
     ])
    
     static let neonRipples: ColorMap = ColorMap(stops: [
         ColorStop(position: 0.32, type: .single(.black)),
         ColorStop(position: 0.33, type: .single(.cyan)),
         ColorStop(position: 0.34, type: .single(.black)),
         ColorStop(position: 0.65, type: .single(.black)),
         ColorStop(position: 0.66, type: .single(.cyan)),
         ColorStop(position: 0.67, type: .single(.black))
     ])
    
     static let appleTwoRiver: ColorMap = ColorMap(stops: [
         ColorStop(position: 0.32, type: .single(.black)),
         ColorStop(position: 0.33, type: .single(.green)),
         ColorStop(position: 0.34, type: .single(.init(red: 0.0, green: 0.1, blue: 0.0, alpha: 1))),
         ColorStop(position: 0.65, type: .single(.init(red: 0.0, green: 0.1, blue: 0.0, alpha: 1))),
         ColorStop(position: 0.66, type: .single(.green)),
         ColorStop(position: 0.67, type: .single(.black)),
     ])
    
     static let electoralMap: ColorMap = ColorMap(stops: [
         ColorStop(position: 0.32, type: .single(.init(red: 0.1, green: 0.0, blue: 0.0, alpha: 1))),
         ColorStop(position: 0.33, type: .single(.red)),
         ColorStop(position: 0.34, type: .single(.make(redInt: 33, green: 0, blue: 51))),
         ColorStop(position: 0.65, type: .single(.make(redInt: 33, green: 0, blue: 51))),
         ColorStop(position: 0.66, type: .single(.blue)),
         ColorStop(position: 0.67, type: .single(.init(red: 0.0, green: 0.0, blue: 0.15, alpha: 1)))
     ])
    
     static let topographic = ColorMap(stops: [
         ColorStop(position: 0.300, type: .dual(.topoBlue, .topoBrown)),
         ColorStop(position: 0.305, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.350, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.355, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.400, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.405, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.450, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.455, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.500, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.505, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.550, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.555, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.600, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.605, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.650, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.655, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.700, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.705, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.750, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.755, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.800, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.805, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.850, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.855, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.900, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.905, type: .dual(.topoBrown, .topoGreen)),
         ColorStop(position: 0.950, type: .dual(.topoGreen, .topoBrown)),
         ColorStop(position: 0.955, type: .dual(.topoBrown, .topoGreen))
     ])
 }
