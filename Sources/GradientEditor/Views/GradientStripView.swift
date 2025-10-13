import SwiftUI

/// Displays the gradient strip with draggable color stop handles.
struct GradientStripView<PinchGesture: Gesture, PanGestureType: Gesture>: View {
    let viewModel: GradientEditViewModel
    let geometry: GradientLayoutGeometry
    let onStopDragChanged: (DragHandleViewModel, CGFloat) -> Void
    let onStopDragEnded: (DragHandleViewModel) -> Void
    let onStopTap: (DragHandleViewModel) -> Void

    @Binding var isDraggingHandle: Bool
    @GestureState private var isActiveDrag: Bool = false

    let pinchGesture: PinchGesture
    let panGesture: PanGestureType

    var body: some View {
        ZStack(alignment: geometry.orientation == .vertical ? .topTrailing : .topLeading) {
            // Gradient rectangle
            Rectangle()
                .fill(gradientFill)
                .frame(
                    width: geometry.orientation == .vertical ? geometry.stripWidth : geometry.stripLength,
                    height: geometry.orientation == .vertical ? geometry.stripLength : geometry.stripWidth
                )
                .simultaneousGesture(pinchGesture)
                .simultaneousGesture(panGesture)
                .accessibilityLabel(AccessibilityLabels.gradientPreview)
                .accessibilityIdentifier(AccessibilityIdentifiers.gradientStrip)

            // Selected stop indicator
            if let editPos = selectedStopViewPosition {
                Rectangle()
                    .fill(Color.white)
                    .frame(
                        width: geometry.orientation == .vertical ? geometry.stripWidth : 1,
                        height: geometry.orientation == .vertical ? 1 : geometry.stripWidth
                    )
                    .offset(
                        x: geometry.orientation == .horizontal ? editPos : 0,
                        y: geometry.orientation == .vertical ? editPos : 0
                    )
                    .opacity(0.8)
            }

            // Drag handles
            ForEach(viewModel.dragHandleViewModels) { handleVM in
                if let offset = geometry.handleOffset(for: handleVM.position) {
                    DragHandle(viewModel: handleVM, isHorizontal: geometry.orientation == .horizontal)
                        .offset(offset)
                        .highPriorityGesture(stopDragGesture(for: handleVM))
                        .gesture(stopTapGesture(for: handleVM))
                }
            }
        }
        .frame(
            width: geometry.orientation == .vertical ? geometry.stripWidth : geometry.stripLength,
            height: geometry.orientation == .vertical ? geometry.stripLength : geometry.stripWidth
        )
        .coordinateSpace(name: "gradientStrip")
        .onChange(of: isActiveDrag) { _, newValue in
            isDraggingHandle = newValue
        }
    }

    // MARK: - Helper Computed Properties

    /// Orientation-aware gradient fill
    private var gradientFill: LinearGradient {
        let visibleRange = geometry.visibleRangeStart...geometry.visibleRangeEnd
        let visibleSpan = geometry.visibleRangeEnd - geometry.visibleRangeStart

        // Transform stops to visible range coordinates
        var gradStops: [Gradient.Stop] = []

        // Add edge color at start if needed (for stops before visible range)
        if let firstVisibleStop = viewModel.colorStops.first(where: { $0.position >= visibleRange.lowerBound }) {
            if firstVisibleStop.position > visibleRange.lowerBound {
                // Find the color at the start of visible range
                let startColor = interpolatedColor(at: visibleRange.lowerBound)
                gradStops.append(Gradient.Stop(color: startColor, location: 0.0))
            }
        }

        // Add visible stops with transformed locations
        for cStop in viewModel.colorStops where visibleRange.contains(cStop.position) {
            let transformedLocation = (cStop.position - geometry.visibleRangeStart) / visibleSpan

            switch cStop.type {
            case .single(let color):
                gradStops.append(Gradient.Stop(color: Color(cgColor: color), location: transformedLocation))
            case .dual(let colorA, let colorB):
                gradStops.append(Gradient.Stop(color: Color(cgColor: colorA), location: transformedLocation))
                gradStops.append(Gradient.Stop(color: Color(cgColor: colorB), location: transformedLocation))
            }
        }

        // Add edge color at end if needed (for stops after visible range)
        if let lastVisibleStop = viewModel.colorStops.last(where: { $0.position <= visibleRange.upperBound }) {
            if lastVisibleStop.position < visibleRange.upperBound {
                // Find the color at the end of visible range
                let endColor = interpolatedColor(at: visibleRange.upperBound)
                gradStops.append(Gradient.Stop(color: endColor, location: 1.0))
            }
        }

        // Fallback: if no stops in range, use interpolated colors at edges
        if gradStops.isEmpty {
            gradStops = [
                Gradient.Stop(color: interpolatedColor(at: visibleRange.lowerBound), location: 0.0),
                Gradient.Stop(color: interpolatedColor(at: visibleRange.upperBound), location: 1.0)
            ]
        }

        // Set gradient direction based on orientation
        if geometry.orientation == .vertical {
            return LinearGradient(stops: gradStops, startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(stops: gradStops, startPoint: .leading, endPoint: .trailing)
        }
    }

    /// Interpolates the color at a given position in the gradient.
    /// - Parameter position: Position in gradient space (0.0-1.0).
    /// - Returns: The interpolated color at that position.
    private func interpolatedColor(at position: CGFloat) -> Color {
        let stops = viewModel.colorStops

        // Handle edge cases
        if stops.isEmpty {
            return .clear
        }
        if position <= stops.first!.position {
            return Color(cgColor: stops.first!.type.startColor)
        }
        if position >= stops.last!.position {
            return Color(cgColor: stops.last!.type.endColor)
        }

        // Find surrounding stops
        var prevStop: ColorStop?
        var nextStop: ColorStop?

        for stop in stops {
            if stop.position <= position {
                prevStop = stop
            }
            if stop.position >= position && nextStop == nil {
                nextStop = stop
            }
        }

        guard let prev = prevStop, let next = nextStop else {
            return .clear
        }

        if prev == next {
            return Color(cgColor: prev.type.startColor)
        }

        // Interpolate between stops
        let t = (position - prev.position) / (next.position - prev.position)
        let fromColor = prev.type.endColor
        let toColor = next.type.startColor

        return Color(cgColor: interpolate(from: fromColor, to: toColor, t: t))
    }

    /// Interpolates between two CGColors.
    private func interpolate(from: CGColor, to: CGColor, t: CGFloat) -> CGColor {
        guard let fromComponents = from.components,
              let toComponents = to.components else {
            return from
        }

        let fromRGB = fromComponents.count >= 3 ? fromComponents : [fromComponents[0], fromComponents[0], fromComponents[0], fromComponents.count > 1 ? fromComponents[1] : 1.0]
        let toRGB = toComponents.count >= 3 ? toComponents : [toComponents[0], toComponents[0], toComponents[0], toComponents.count > 1 ? toComponents[1] : 1.0]

        let r = fromRGB[0] + (toRGB[0] - fromRGB[0]) * t
        let g = fromRGB[1] + (toRGB[1] - fromRGB[1]) * t
        let b = fromRGB[2] + (toRGB[2] - fromRGB[2]) * t
        let a = fromRGB[3] + (toRGB[3] - fromRGB[3]) * t

        return CGColor(srgbRed: r, green: g, blue: b, alpha: a)
    }

    private var selectedStopViewPosition: CGFloat? {
        guard viewModel.isEditingStop else { return nil }
        return geometry.viewCoordinate(for: viewModel.editPosition)
    }

    // MARK: - Gestures

    private func stopDragGesture(for handleVM: DragHandleViewModel) -> some Gesture {
        DragGesture(coordinateSpace: .named("gradientStrip"))
            .updating($isActiveDrag) { _, state, _ in
                state = true
            }
            .onChanged { value in
                let coord: CGFloat = geometry.orientation == .vertical
                    ? value.location.y
                    : value.location.x
                onStopDragChanged(handleVM, coord)
            }
            .onEnded { _ in
                onStopDragEnded(handleVM)
            }
    }

    private func stopTapGesture(for handleVM: DragHandleViewModel) -> some Gesture {
        TapGesture()
            .onEnded {
                onStopTap(handleVM)
            }
    }
}
