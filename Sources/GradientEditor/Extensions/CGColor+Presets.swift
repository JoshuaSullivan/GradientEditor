import CoreGraphics

public extension CGColor {
    
    static let topoBlue = CGColor.make(redInt: 220, green: 220, blue: 254)
    static let topoGreen = CGColor.make(redInt: 238, green: 249, blue: 217)
    static let topoBrown = CGColor.make(redInt: 167, green: 141, blue: 112)

    static let black = CGColor.make(redInt: 0, green: 0, blue: 0)
    static let white = CGColor.make(redInt: 255, green: 255, blue: 255)
    static let cyan = CGColor.make(redInt: 0, green: 255, blue: 255)
    static let green = CGColor.make(redInt: 0, green: 255, blue: 0)
    static let red = CGColor.make(redInt: 255, green: 0, blue: 0)
    static let blue = CGColor.make(redInt: 0, green: 0, blue: 255)
    static let orange = CGColor.make(redInt: 255, green: 165, blue: 0)
    static let yellow = CGColor.make(redInt: 255, green: 255, blue: 0)
    static let purple = CGColor.make(redInt: 128, green: 0, blue: 128)
    
    
    static func make(redInt: Int, green: Int, blue: Int) -> CGColor {
        CGColor(red: Double(redInt) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: 1.0)
    }
    
    static func make(gray: CGFloat) -> CGColor {
        CGColor(red: gray, green: gray, blue: gray, alpha: 1.0)
    }
}

