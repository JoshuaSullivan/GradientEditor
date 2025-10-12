import Foundation

extension Float {
    /// Allows Binding<Double> to be used with a Float value.
    var double: Double {
        get { Double(self) }
        set { self = Float(newValue) }
    }
}
