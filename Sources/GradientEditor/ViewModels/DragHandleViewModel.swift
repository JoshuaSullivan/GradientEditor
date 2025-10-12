import SwiftUI

@Observable
public class DragHandleViewModel: Identifiable {
    public let id: String
    public private(set) var colorStopType: ColorStopType
    public private(set) var position: CGFloat
    
    init(colorStop: ColorStop) {
        self.id = colorStop.id
        self.colorStopType = colorStop.type
        self.position = colorStop.position
    }
    
    func update(with colorStop: ColorStop) {
        self.colorStopType = colorStop.type
        self.position = colorStop.position
    }
}
