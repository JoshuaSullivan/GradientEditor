import CoreImage
import SwiftUI

/// Color Presets
public struct GradientColorScheme: Identifiable, Equatable, Codable, Hashable, Comparable, Sendable {
    /// Unique identifier.
    public let id: UUID
    
    /// Name of the color scheme.
    public let name: String
    
    /// Description of the color scheme.
    public let description: String

    /// The color map for the color scheme.
    public let colorMap: ColorMap
    
    /// Create a new instance of GradientColorScheme.
    /// - Parameters:
    ///   - id: The unique identifier for the color scheme.
    ///   - name: The name of the color scheme.
    ///   - description: The description of the color scheme.
    ///   - colorMap: The color map for the color scheme.
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
    
     // Helper to get all presets
     static var allPresets: [GradientColorScheme] {
         [blackAndWhite, wakeIsland, neonRipples, appleTwoRiver, electoralMap, topographic]
     }
    
     // Static presets to replace enum cases
     static let blackAndWhite = GradientColorScheme(
         name: "Black & White",
         description: "A simple, black-and-white color scheme that is good for input into filter effects.",
         colorMap: .blackAndWhite
     )
    
     static let wakeIsland = GradientColorScheme(
         name: "Wake Island",
         description: "A tropical island color scheme sampled from photos of Wake Island.",
         colorMap: .wakeIsland
     )
    
     static let neonRipples = GradientColorScheme(
         name: "Neon Ripples",
         description: "An abstract color set of snaking lines.",
         colorMap: .neonRipples
     )
    
     static let appleTwoRiver = GradientColorScheme(
         name: "Apple ][ River",
         description: "Inspired by the green CRT monitor that came with the Apple ][ computer.",
         colorMap: .appleTwoRiver
     )
    
     static let electoralMap = GradientColorScheme(
         name: "Electoral Map",
         description: "Red vs. Blue",
         colorMap: .electoralMap
     )
    
     static let topographic = GradientColorScheme(
         name: "Topographic",
         description: "Resembles a topographic map.",
         colorMap: .topographic
     )
    
     // MARK: - Codable Example Methods
    
     /// Encode a GradientColorScheme to JSON data
     /// - Returns: JSON data representation of the GradientColorScheme
     func toJSON() throws -> Data {
         let encoder = JSONEncoder()
         encoder.outputFormatting = .prettyPrinted
         return try encoder.encode(self)
     }
    
     /// Create a GradientColorScheme from JSON data
     /// - Parameter data: JSON data to decode
     /// - Returns: A GradientColorScheme instance
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
