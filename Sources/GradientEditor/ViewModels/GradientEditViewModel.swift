import SwiftUI
import Combine

/// The main view model for gradient editing.
///
/// `GradientEditViewModel` manages all state and logic for editing gradients, including:
/// - Color stop management (add, delete, modify, duplicate)
/// - Zoom and pan state (1x to 4x zoom)
/// - Selection and editing state
/// - Completion callbacks for save/cancel
///
/// This view model must be created on the main actor and is designed to be used with ``GradientEditView``.
///
/// ## Topics
///
/// ### Creating a View Model
/// - ``init(scheme:onComplete:)``
///
/// ### State Properties
/// - ``scheme``
/// - ``colorStops``
/// - ``selectedStop``
/// - ``isEditingStop``
/// - ``zoomLevel``
/// - ``panOffset``
/// - ``gradientFill``
///
/// ### Stop Management
/// - ``addTapped()``
/// - ``stopTapped(_:)``
/// - ``update(colorStopId:position:)``
///
/// ### Zoom and Pan
/// - ``updateZoom(_:)``
/// - ``updatePan(_:)``
///
/// ### Completion
/// - ``saveGradient()``
/// - ``cancelEditing()``
///
/// ## Example
/// ```swift
/// let viewModel = GradientEditViewModel(
///     scheme: .wakeIsland
/// ) { result in
///     switch result {
///     case .saved(let scheme):
///         print("Saved gradient '\(scheme.name)' with \(scheme.colorMap.stops.count) stops")
///     case .cancelled:
///         print("Editing cancelled")
///     }
/// }
/// ```
@Observable
@MainActor
public class GradientEditViewModel {

    /// ID for uniqueness.
    let id: String = UUID().uuidString

    /// Completion handler called when editing is complete.
    ///
    /// This callback receives a ``GradientEditorResult`` indicating whether the user saved or cancelled.
    public var onComplete: (@Sendable (GradientEditorResult) -> Void)?

    /// Current zoom level (1.0 = 100%, 4.0 = 400%).
    ///
    /// Use ``updateZoom(_:)`` to modify this value, which clamps to the valid range.
    public var zoomLevel: CGFloat = 1.0

    /// Current pan offset (0.0 - 1.0, where 0.5 is centered).
    ///
    /// Only applicable when ``zoomLevel`` is greater than 1.0.
    /// Use ``updatePan(_:)`` to modify this value.
    public var panOffset: CGFloat = 0.0

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

    public var scheme: GradientColorScheme

    public private(set) var selectedStop: ColorStop?
    public var editPosition: CGFloat = 0.5
    
    private var subs = Set<AnyCancellable>()
    
    /// Creates a new gradient edit view model.
    ///
    /// - Parameters:
    ///   - scheme: The gradient scheme to edit.
    ///   - onComplete: Optional callback invoked when editing completes with save or cancel.
    ///
    /// ## Example
    /// ```swift
    /// let viewModel = GradientEditViewModel(scheme: .wakeIsland) { result in
    ///     switch result {
    ///     case .saved(let scheme):
    ///         // Handle saved gradient scheme
    ///         saveGradient(scheme)
    ///     case .cancelled:
    ///         // Handle cancellation
    ///         break
    ///     }
    /// }
    /// ```
    public init(scheme: GradientColorScheme, onComplete: (@Sendable (GradientEditorResult) -> Void)? = nil) {

        self.scheme = scheme
        self.stops = Set(scheme.colorMap.stops)
        dragHandleViewModels = scheme.colorMap.stops.map { DragHandleViewModel(colorStop: $0) }
        self.onComplete = onComplete

        colorStopViewModel.actionPublisher
            .sink(receiveValue: handle(action:))
            .store(in: &subs)
    }

    /// Updates the position of a specific color stop.
    ///
    /// - Parameters:
    ///   - colorStopId: The unique identifier of the stop to update.
    ///   - position: The new position (typically 0.0 to 1.0).
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

    /// Handles tapping on a color stop to select it for editing.
    ///
    /// - Parameter stopId: The unique identifier of the stop to select.
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

    /// Adds a new color stop at position 0.5 with a random color.
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
        guard colorStopViewModel.canDelete else { return }
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
        case .duplicate:
            duplicateSelectedStop()
        case .close:
            isEditingStop = false
            selectedStop = nil
        }
    }

    private func duplicateSelectedStop() {
        guard let currentStop = selectedStop else { return }

        // Calculate position for the duplicate
        let sortedStops = colorStops
        guard let currentIndex = sortedStops.firstIndex(of: currentStop) else { return }

        let newPosition: CGFloat
        if currentIndex < sortedStops.count - 1 {
            // Not the last stop: place halfway to next stop
            let nextStop = sortedStops[currentIndex + 1]
            newPosition = (currentStop.position + nextStop.position) / 2.0
        } else if currentIndex > 0 {
            // Last stop: place halfway to previous stop
            let prevStop = sortedStops[currentIndex - 1]
            newPosition = (prevStop.position + currentStop.position) / 2.0
        } else {
            // Only one stop: place at midpoint
            newPosition = 0.5
        }

        // Create duplicate with new position
        let duplicateStop = ColorStop(position: newPosition, type: currentStop.type)
        stops.insert(duplicateStop)
        dragHandleViewModels.append(DragHandleViewModel(colorStop: duplicateStop))

        // Select the new stop
        activate(stop: duplicateStop)
    }
    
    /// Saves the edited gradient and calls the completion handler.
    ///
    /// Creates a ``GradientColorScheme`` from the current color stops and invokes the completion
    /// callback with ``GradientEditorResult/saved(_:)``. The scheme preserves the original name
    /// and description from the input scheme.
    public func saveGradient() {
        let updatedColorMap = ColorMap(id: scheme.colorMap.id, stops: colorStops)
        let updatedScheme = GradientColorScheme(
            id: scheme.id,
            name: scheme.name,
            description: scheme.description,
            colorMap: updatedColorMap
        )
        onComplete?(.saved(updatedScheme))
    }

    /// Cancels editing without saving and calls the completion handler.
    ///
    /// Invokes the completion callback with ``GradientEditorResult/cancelled``.
    public func cancelEditing() {
        onComplete?(.cancelled)
    }

    /// Updates the zoom level, clamping to valid range (1.0 - 4.0).
    ///
    /// When zoom is reset to 1.0, the pan offset is automatically reset to 0.0.
    ///
    /// - Parameter newZoom: The desired zoom level (will be clamped to 1.0-4.0 range).
    public func updateZoom(_ newZoom: CGFloat) {
        zoomLevel = max(1.0, min(4.0, newZoom))

        // Reset pan if zoom is back to 100%
        if zoomLevel == 1.0 {
            panOffset = 0.0
        }
    }

    /// Updates the pan offset, clamping to valid range (0.0 - 1.0).
    ///
    /// Pan offset is only applied when ``zoomLevel`` is greater than 1.0.
    /// A value of 0.0 shows the start of the gradient, 1.0 shows the end.
    ///
    /// - Parameter newPan: The desired pan offset (will be clamped to 0.0-1.0 range).
    public func updatePan(_ newPan: CGFloat) {
        guard zoomLevel > 1.0 else {
            panOffset = 0.0
            return
        }
        panOffset = max(0.0, min(1.0, newPan))
    }

    /// Updates the scheme metadata (name and description).
    ///
    /// - Parameters:
    ///   - name: The new name for the gradient scheme.
    ///   - description: The new description for the gradient scheme.
    public func updateSchemeMetadata(name: String, description: String) {
        scheme = GradientColorScheme(
            id: scheme.id,
            name: name,
            description: description,
            colorMap: scheme.colorMap
        )
    }

}
