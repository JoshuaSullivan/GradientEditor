import SwiftUI

/// A wrapper for the SwiftUI Color type that allows for encoding and decoding.
public struct CodableColor: Codable {
    
    private enum CodingKeys: CodingKey {
        case red, green, blue, alpha
    }
    
    /// The color to encode and decode.
    public let color: Color
    
    /// The environment in which the color is used.
    public var environment: EnvironmentValues?
    
    public init(color: Color, environment: EnvironmentValues) {
        self.color = color
        self.environment = environment
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        color = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        environment = nil
    }
    
    public func encode(to encoder: any Encoder) throws {
        guard let environment else {
            throw EncodingError.invalidValue("environment", EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "environment is nil, which prevents encoding the color."))
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        let resolved = color.resolve(in: environment)
        try container.encode(Double(resolved.red), forKey: .red)
        try container.encode(Double(resolved.green), forKey: .green)
        try container.encode(Double(resolved.blue), forKey: .blue)
        try container.encode(Double(resolved.opacity), forKey: .alpha)
    }
}
