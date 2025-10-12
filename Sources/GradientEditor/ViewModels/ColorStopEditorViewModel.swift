import SwiftUI
import Combine

@Observable
public class ColorStopEditorViewModel {
    
    public enum Action {
        case updatedStop(ColorStop)
        case prev
        case next
        case delete
        case close
    }
    
    public var actionPublisher: AnyPublisher<Action, Never> {
        _actionPublisher.eraseToAnyPublisher()
    }
    
    private let _actionPublisher = PassthroughSubject<Action, Never>()
    
    public var isSingleColorStop: Bool = true {
        didSet { sendUpdatedColorStop() }
    }
    
    public var firstcolor: CGColor = .red {
        didSet { sendUpdatedColorStop() }
    }
    
    public var secondColor: CGColor = .blue {
        didSet { sendUpdatedColorStop() }
    }
    
    public var position: CGFloat = 0.5 {
        didSet { sendUpdatedColorStop() }
    }
    
    public var canDelete: Bool = true
    
    private var id: String
    
    init(colorStop: ColorStop) {
        self.id = colorStop.id
        self.position = colorStop.position
        switch colorStop.type {
        case let .single(firstColor):
            isSingleColorStop = true
            self.firstcolor = firstColor
        case let .dual(firstColor, secondColor):
            isSingleColorStop = false
            self.firstcolor = firstColor
            self.secondColor = secondColor
        }
    }
    
    private func sendUpdatedColorStop() {
        let stop: ColorStop
        if isSingleColorStop {
            stop = ColorStop(id: id, position: position, type: .single(firstcolor))
        } else {
            stop = ColorStop(id: id, position: position, type: .dual(firstcolor, secondColor))
        }
        _actionPublisher.send(.updatedStop(stop))
    }
    
    public func change(colorStop: ColorStop) {
        self.id = colorStop.id
        self.position = colorStop.position
        switch colorStop.type {
        case let .single(firstColor):
            isSingleColorStop = true
            self.firstcolor = firstColor
        case let .dual(firstColor, secondColor):
            isSingleColorStop = false
            self.firstcolor = firstColor
            self.secondColor = secondColor
        }
    }
    
    public func prevTapped() {
        _actionPublisher.send(.prev)
    }
    
    public func nextTapped() {
        _actionPublisher.send(.next)
    }
    
    public func closeTapped() {
        _actionPublisher.send(.close)
    }
    
    public func deleteTapped() {
        _actionPublisher.send(.delete)
    }
}
