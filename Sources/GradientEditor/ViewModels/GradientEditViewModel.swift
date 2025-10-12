import SwiftUI
import Combine

@Observable
public class GradientEditViewModel: Equatable, Hashable {
    
    /// ID for uniqueness.
    let id: String = UUID().uuidString
    
    public var gradientFill: LinearGradient {
        let gradStops = colorStops.flatMap { cStop in
            switch cStop.type {
            case .single(let color):
                return [Gradient.Stop(color: Color(cgColor: color), location: cStop.position)]
            case .dual(let colorA, let colorB):
                return [Gradient.Stop(color: Color(cgColor: colorA), location: cStop.position), Gradient.Stop(color: Color(cgColor: colorB), location: cStop.position)]
            }
        }
        return LinearGradient(stops: gradStops, startPoint: .top, endPoint: .bottom)
    }
    
    public var colorStopViewModel: ColorStopEditorViewModel = ColorStopEditorViewModel(colorStop: .defaultStart)
    
    private var stops: Set<ColorStop> {
        didSet {
            colorStopViewModel.canDelete = stops.count > 2
        }
    }
    
    public var colorStops: [ColorStop] {
        stops.sorted()
    }
    
    public var dragHandleViewModels: [DragHandleViewModel]
    
    public var isEditingStop: Bool = false
    
    public var environment: EnvironmentValues = EnvironmentValues()
    
    public private(set) var scheme: ColorScheme
    
    public private(set) var selectedStop: ColorStop?
    public var editPosition: CGFloat = 0.5
    
    private var subs = Set<AnyCancellable>()
    
    public init(scheme: ColorScheme) {
        
        self.scheme = scheme
        self.stops = Set(scheme.colorMap.stops)
        dragHandleViewModels = scheme.colorMap.stops.map { DragHandleViewModel(colorStop: $0) }
        
        colorStopViewModel.actionPublisher
            .sink(receiveValue: handle(action:))
            .store(in: &subs)
    }
    
    public func update(colorStopId: String, position: CGFloat) {
        guard 
            let stop = stops.first(where: { $0.id == colorStopId }),
            let vm = dragHandleViewModels.first(where: { $0.id == colorStopId })
        else {
            assertionFailure("Couldn't find ColorStop or DragHandleViewModel with provided id.")
            return
        }
        let newStop = ColorStop(id: stop.id, position: position, type: stop.type)
        vm.update(with: newStop)
        stops.remove(stop)
        stops.insert(newStop)
        editPosition = position
    }
    
    public func stopTapped(_ stopId: String) {
        guard let stop = stops.first(where: { $0.id == stopId }) else {
            assertionFailure("Couldn't find selected stop!")
            return
        }
        activate(stop: stop)
        isEditingStop = true
        selectedStop = stop
        editPosition = stop.position
    }
    
    public func addTapped() {
        let colors: [CGColor] = [.red, .orange, .yellow, .green, .blue, .purple]
        let color = colors[Int.random(in: 0..<colors.count)]
        let stop = ColorStop(position: 0.5, type: .single(color))
        stops.insert(stop)
        dragHandleViewModels.append(DragHandleViewModel(colorStop: stop))
    }
    
    private func activate(stop: ColorStop) {
        selectedStop = stop
        colorStopViewModel.change(colorStop: stop)
        editPosition = stop.position
    }
    
    private func update(colorStop: ColorStop) {
        guard 
            let oldStop = stops.first(where: { $0.id == colorStop.id }),
            let vm = dragHandleViewModels.first(where: { $0.id == colorStop.id })
        else { return }
        stops.remove(oldStop)
        stops.insert(colorStop)
        vm.update(with: colorStop)
        editPosition = colorStop.position
    }
    
    private func deleteSelectedStop() {
        guard let id = selectedStop?.id else { return }
        selectNextStop()
        dragHandleViewModels.removeAll { $0.id == id }
        stops = stops.filter { $0.id != id }
    }
    
    private func selectNextStop() {
        let cs = colorStops
        guard
            let stop = selectedStop,
            let currentIndex = cs.firstIndex(of: stop) else
        {
            assertionFailure("Couldn't find stop.")
            return
        }
        let c = cs.count
        let nextIndex = (currentIndex + 1) % c
        activate(stop: cs[nextIndex])
    }
    
    private func selectPrevStop() {
        let cs = colorStops
        guard
            let stop = selectedStop,
            let currentIndex = cs.firstIndex(of: stop) else
        {
            assertionFailure("Couldn't find stop.")
            return
        }
        let c = cs.count
        let nextIndex = (currentIndex + c - 1) % c
        activate(stop: cs[nextIndex])
    }
    
    private func handle(action: ColorStopEditorViewModel.Action) {
        switch action {
        case .updatedStop(let colorStop):
            update(colorStop: colorStop)
        case .prev:
            selectPrevStop()
        case .next:
            selectNextStop()
        case .delete:
            deleteSelectedStop()
        case .close:
            isEditingStop = false
            selectedStop = nil
        }
    }
    
    public func exportGradient() {
        let grad = ColorMap(stops: colorStops)
        do {
            let json = try JSONEncoder().encode(grad)
            let jsonString = String(data: json, encoding: .utf8)!
            print(jsonString)
            importGradient(data: json)
        } catch {
            print("Error encoding gradient: \(error)")
        }
    }
    
    public func importGradient(data: Data) {
        do {
            let grad = try JSONDecoder().decode(ColorMap.self, from: data)
            print(grad)
        } catch {
            print("Error decoding gradient: \(error)")
        }
    }
    
    // MARK: - Equatable & Hashable
    
    public static func == (lhs: GradientEditViewModel, rhs: GradientEditViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
