import Foundation

/// A custom gradient that can be applied in Landmass.
public struct ColorMap: Identifiable, Equatable, Hashable, Codable, Sendable {
    /// The unique ID of the gradient.
    public let id: String
        
    /// An array of 1 or more color stops that define the gradient.
    public let stops: [ColorStop]
    
    /// Creates a new custom gradient.
    /// - Parameters:
    ///  - id: The unique ID of the gradient.
    ///  - name: The display name of the gradient.
    ///  - stops: An array of 1 or more color stops that define the gradient.
    ///
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
