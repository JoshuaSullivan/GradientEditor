import SwiftUI

/// A single color stop within a gradient.
///
/// `ColorStop` represents a color (or pair of colors) at a specific position along a gradient.
/// Each stop has a ``position`` between 0.0 and 1.0, and a ``type`` that determines whether
/// it displays a single color or transitions between two colors at that position.
///
/// Color stops are comparable based on their position, allowing for easy sorting.
///
/// ## Topics
///
/// ### Creating a Color Stop
/// - ``init(id:position:type:)``
///
/// ### Default Stops
/// - ``defaultStart``
/// - ``defaultEnd``
///
/// ### Properties
/// - ``id``
/// - ``position``
/// - ``type``
///
/// ## Example
/// ```swift
/// // Single color stop
/// let redStop = ColorStop(position: 0.0, type: .single(.red))
///
/// // Dual color stop (hard transition)
/// let transitionStop = ColorStop(position: 0.5, type: .dual(.blue, .yellow))
/// ```
nonisolated
public struct ColorStop: Identifiable, Equatable, Hashable, Comparable, Codable, Sendable {

    /// The unique identifier for this color stop.
    public let id: String

    /// The position of this stop along the gradient, from 0.0 (start) to 1.0 (end).
    ///
    /// This value should typically be between 0.0 and 1.0, though values outside this
    /// range may be used for special effects.
    public var position: CGFloat

    /// The color type of this stop.
    ///
    /// Can be either a single color or a dual-color transition at this position.
    /// See ``ColorStopType`` for more details.
    public var type: ColorStopType

    /// Creates a new color stop.
    ///
    /// - Parameters:
    ///   - id: A unique identifier. Defaults to a new UUID string if not provided.
    ///   - position: The position along the gradient (0.0 to 1.0). Defaults to 0.0.
    ///   - type: The color type (single or dual).
    ///
    /// ## Example
    /// ```swift
    /// // Create a red stop at the beginning
    /// let stop = ColorStop(
    ///     position: 0.0,
    ///     type: .single(.red)
    /// )
    /// ```
    public init(id: String = UUID().uuidString, position: CGFloat = 0.0, type: ColorStopType) {
        self.id = id
        self.position = position
        self.type = type
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: ColorStop, rhs: ColorStop) -> Bool {
        lhs.id == rhs.id
    }
    
    public static func < (lhs: ColorStop, rhs: ColorStop) -> Bool {
        lhs.position < rhs.position
    }
    
    // MARK: - Codable
    nonisolated
    enum CodingKeys: CodingKey {
        case id
        case position
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        position = try container.decode(CGFloat.self, forKey: .position)
        type = try container.decode(ColorStopType.self, forKey: .type)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(position, forKey: .position)
        try container.encode(type, forKey: .type)
    }
}

nonisolated
public extension ColorStop {

    /// The default starting color stop (red at position 0.0).
    ///
    /// Use this as a placeholder when no custom start color has been defined.
    static let defaultStart = ColorStop(position: 0.0, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))

    /// The default ending color stop (blue at position 1.0).
    ///
    /// Use this as a placeholder when no custom end color has been defined.
    static let defaultEnd = ColorStop(position: 1.0, type: .single(CGColor(red: 0, green: 0, blue: 1, alpha: 1)))
}
