import Foundation

/// A collection of color stops defining a gradient.
///
/// `ColorMap` is the core data structure representing a gradient. It contains an ordered
/// collection of ``ColorStop`` values, each defining a color at a specific position along the gradient.
///
/// The stops array preserves the order in which stops are provided and is not automatically sorted.
/// For proper gradient rendering, stops should generally be ordered by their position values.
///
/// ## Topics
///
/// ### Creating a Color Map
/// - ``init(id:stops:)``
///
/// ### Properties
/// - ``id``
/// - ``stops``
///
/// ## Example
/// ```swift
/// let colorMap = ColorMap(stops: [
///     ColorStop(position: 0.0, type: .single(.red)),
///     ColorStop(position: 0.5, type: .single(.yellow)),
///     ColorStop(position: 1.0, type: .single(.green))
/// ])
/// ```
public struct ColorMap: Identifiable, Equatable, Hashable, Codable, Sendable {

    /// The unique identifier for this color map.
    public let id: String

    /// The array of color stops defining the gradient.
    ///
    /// The order of stops is preserved as provided. For typical gradients, stops should
    /// be ordered by their ``ColorStop/position`` values from 0.0 to 1.0.
    public let stops: [ColorStop]

    /// Creates a new color map.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID string if not provided.
    ///   - stops: An array of color stops. Must contain at least one stop for a valid gradient.
    ///
    /// ## Example
    /// ```swift
    /// // Simple two-color gradient
    /// let gradient = ColorMap(stops: [
    ///     ColorStop(position: 0.0, type: .single(.blue)),
    ///     ColorStop(position: 1.0, type: .single(.purple))
    /// ])
    /// ```
    public init(id: String = UUID().uuidString, stops: [ColorStop]) {
        self.id = id
        self.stops = stops
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: ColorMap, rhs: ColorMap) -> Bool {
        lhs.id == rhs.id
    }
    
    /// MARK: - Codable
    
    private enum CodingKeys: CodingKey {
        case id
        case stops
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        stops = try container.decode([ColorStop].self, forKey: .stops)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(stops, forKey: .stops)
    }
}
