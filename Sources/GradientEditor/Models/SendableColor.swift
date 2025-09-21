import UIKit

/// A Sendable proxy for CGColors.
public struct SendableColor: Sendable {
    
    /// The red component of the color.
    public let red: Double
    
    /// The green component of the color.
    public let green: Double
    
    /// The blue component of the color.
    public let blue: Double
    
    /// The alpha component of the color.
    public let alpha: Double
    
    /// Create a new SendableColor with direct values.
    nonisolated
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    /// Create a new SendableColor with the provided CGColor.
    ///
    /// The color must have color components (as opposed to a pattern, or something else) or the initializer will fail.
    ///
    nonisolated
    public init?(_ color: CGColor) {
        guard let comps = color.components else { return nil }
        if comps.count == 4 {
            self.red = comps[0]
            self.green = comps[1]
            self.blue = comps[2]
            self.alpha = comps[3]
        } else if comps.count == 3 {
            self.red = comps[0]
            self.green = comps[1]
            self.blue = comps[2]
            self.alpha = 1.0
        } else if comps.count == 2 {
            self.red = comps[0]
            self.green = comps[0]
            self.blue = comps[0]
            self.alpha = comps[1]
        } else if comps.count == 1 {
            self.red = comps[0]
            self.green = comps[0]
            self.blue = comps[0]
            self.alpha = 1.0
        } else {
            return nil
        }
    }
    
    nonisolated
    public var cgColor: CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
