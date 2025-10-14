import CoreGraphics

/// The color configuration for a gradient stop.
///
/// `ColorStopType` defines whether a stop uses a single color or transitions between
/// two colors at that specific position. This enables both smooth gradients and hard
/// color transitions within the same gradient.
///
/// ## Topics
///
/// ### Stop Types
/// - ``single(_:)``
/// - ``dual(_:_:)``
///
/// ### Properties
/// - ``title``
/// - ``startColor``
/// - ``endColor``
/// - ``encodingName``
///
/// ## Example
/// ```swift
/// // Smooth single-color stop
/// let smoothStop = ColorStopType.single(.blue)
///
/// // Hard transition between two colors
/// let hardTransition = ColorStopType.dual(.red, .yellow)
/// ```
nonisolated
public enum ColorStopType: Codable, Sendable {

    /// A single color at this position.
    ///
    /// Creates a smooth transition from the previous stop to this color, and from this color
    /// to the next stop.
    case single(CGColor)

    /// Two colors at this position, creating a hard transition.
    ///
    /// The first color ends the gradient segment from the previous stop, and the second color
    /// begins the segment to the next stop. This creates a sharp color boundary at this position.
    case dual(CGColor, CGColor)

    /// A localized display title for this stop type.
    ///
    /// Returns "Single" for single-color stops and "Dual" for dual-color stops.
    public var title: String {
        switch self {
        case .single:
            return LocalizedString.colorStopTypeSingle
        case .dual:
            return LocalizedString.colorStopTypeDual
        }
    }

    /// The encoding name used for serialization.
    ///
    /// Returns "single" or "dual" for use in JSON encoding/decoding.
    public var encodingName: String {
        switch self {
        case .single:
            return "single"
        case .dual:
            return "dual"
        }
    }

    /// The starting color for gradient interpolation.
    ///
    /// For single-color stops, returns the single color. For dual-color stops, returns the first color.
    public var startColor: CGColor {
        switch self {
        case .single(let color):
            return color
        case .dual(let colorA, _):
            return colorA
        }
    }

    /// The ending color for gradient interpolation.
    ///
    /// For single-color stops, returns the single color. For dual-color stops, returns the second color.
    public var endColor: CGColor {
        switch self {
        case .single(let color):
            return color
        case .dual(_, let colorB):
            return colorB
        }
    }
    
    public init?(encodingName: String, firstColor: CGColor, secondColor: CGColor?) {
        if encodingName == "single" {
            self = .single(firstColor)
        } else if encodingName == "dual", let secondColor {
            self = .dual(firstColor, secondColor)
        } else {
            return nil
        }
    }

    // MARK: - Codable
    nonisolated
    enum CodingKeys: CodingKey {
        case type
        case firstColor
        case secondColor
    }
    

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(encodingName, forKey: .type)
        switch self {
        case .single(let color):
            try container.encode(CodableCGColor(color: color), forKey: .firstColor)
        case .dual(let firstColor, let secondColor):
            try container.encode(CodableCGColor(color: firstColor), forKey: .firstColor)
            try container.encode(CodableCGColor(color: secondColor), forKey: .secondColor)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let firstColor = try container.decode(CodableCGColor.self, forKey: .firstColor)
        let secondColor = try container.decodeIfPresent(CodableCGColor.self, forKey: .secondColor)
        guard let stop = ColorStopType(encodingName: type, firstColor: firstColor.color, secondColor: secondColor?.color) else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "The color stop could not be decoded.")
        }
        self = stop
    }
}

nonisolated
private struct CodableCGColor: Codable {

    let color: CGColor

    init(color: CGColor) {
        self.color = color
    }

    nonisolated
    enum CodingKeys: CodingKey {
        case red, green, blue, alpha
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let components = color.components else { throw EncodingError.invalidValue("components", EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "components is nil, which prevents encoding the color.")) }
        try container.encode(components[0] , forKey: .red)
        try container.encode(components[1], forKey: .green)
        try container.encode(components[2], forKey: .blue)
        try container.encode(components[3], forKey: .alpha)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(CGFloat.self, forKey: .red)
        let green = try container.decode(CGFloat.self, forKey: .green)
        let blue = try container.decode(CGFloat.self, forKey: .blue)
        let alpha = try container.decode(CGFloat.self, forKey: .alpha)
        let color = CGColor(red: red, green: green, blue: blue, alpha: alpha)
        self.init(color: color)
    }
}
