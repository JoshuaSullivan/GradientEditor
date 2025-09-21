import SwiftUI

nonisolated
public struct ColorStop: Identifiable, Equatable, Hashable, Comparable, Codable {
    
    public let id: String
    
    public var position: CGFloat
    
    public var type: ColorStopType
    
    public private(set) var environment: EnvironmentValues?
    
    public init(id: String = UUID().uuidString, position: CGFloat = 0.0, type: ColorStopType, environment: EnvironmentValues? = nil) {
        self.id = id
        self.position = position
        self.type = type
        self.environment = environment
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
    
    mutating func set(environment: EnvironmentValues?) {
        self.environment = environment
    }
    
    public func setting(environment: EnvironmentValues?) -> ColorStop {
        return ColorStop(id: id, position: position, type: type, environment: environment)
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
    /// The default starting color stop when none have been user-defined.
    static let defaultStart = ColorStop(position: 0.0, type: .single(CGColor(red: 1, green: 0, blue: 0, alpha: 1)))
    
    /// The default ending color stop when none have been user-defined.
    static let defaultEnd = ColorStop(position: 1.0, type: .single(CGColor(red: 0, green: 0, blue: 1, alpha: 1)))
}
