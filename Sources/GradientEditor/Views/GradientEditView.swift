import SwiftUI

public struct GradientEditView: View {

    @Bindable public var viewModel: GradientEditViewModel

    @GestureState private var magnification: CGFloat = 1.0
    @State private var baseZoom: CGFloat
    @State private var basePan: CGFloat
    @State private var showEditorSheet = false
    @State private var currentGeometry: GradientLayoutGeometry?
    @State private var isDraggingHandle = false

    // Active values during gestures (for immediate visual feedback)
    @State private var activeZoom: CGFloat
    @State private var activePan: CGFloat

    @Environment(\.self) private var environment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Initializer
    public init(viewModel: GradientEditViewModel) {
        self.viewModel = viewModel
        self.baseZoom = viewModel.zoomLevel
        self.basePan = viewModel.panOffset
        self.activeZoom = viewModel.zoomLevel
        self.activePan = viewModel.panOffset
    }

    /// Computes geometry for the current view state.
    private func geometry(for size: CGSize) -> GradientLayoutGeometry {
        GradientLayoutGeometry(
            viewSize: size,
            zoomLevel: activeZoom,
            panOffset: activePan
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            let computedGeometry = geometry(for: proxy.size)

            Group {
                if isCompactWidth {
                    // Compact: show gradient, present editor as sheet
                    gradientView(geometry: computedGeometry)
                        .sheet(isPresented: $showEditorSheet) {
                            editorView
                                .presentationDetents([.medium, .large])
                        }
                } else {
                    // Regular: show side-by-side
                    HStack(spacing: 0) {
                        gradientView(geometry: computedGeometry)

                        if viewModel.isEditingStop {
                            Divider()
                            editorView
                                .frame(width: 300)
                        }
                    }
                }
            }
            .onAppear {
                currentGeometry = computedGeometry
            }
            .onChange(of: proxy.size) { _, _ in
                currentGeometry = computedGeometry
            }
            .onChange(of: activeZoom) { _, _ in
                currentGeometry = computedGeometry
            }
            .onChange(of: activePan) { _, _ in
                currentGeometry = computedGeometry
            }
        }
        .task {
            viewModel.environment = environment
        }
        .padding()
        .animation(.easeInOut, value: viewModel.isEditingStop)
        .onChange(of: viewModel.isEditingStop) { _, isEditing in
            if isCompactWidth {
                showEditorSheet = isEditing
            }
        }
        .onChange(of: viewModel.zoomLevel) { _, newZoom in
            activeZoom = newZoom
            baseZoom = newZoom
        }
        .onChange(of: viewModel.panOffset) { _, newPan in
            activePan = newPan
            basePan = newPan
        }
    }

    // MARK: - Computed Properties

    private var isCompactWidth: Bool {
        horizontalSizeClass == .compact
    }

    // MARK: - Gradient View

    @ViewBuilder
    private func gradientView(geometry: GradientLayoutGeometry) -> some View {
        if geometry.orientation == .vertical {
            verticalGradientLayout(geometry: geometry)
        } else {
            horizontalGradientLayout(geometry: geometry)
        }
    }

    @ViewBuilder
    private func verticalGradientLayout(geometry: GradientLayoutGeometry) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer()

            // Gradient strip with stops
            GradientStripView(
                viewModel: viewModel,
                geometry: geometry,
                onStopDragChanged: handleStopDragChanged,
                onStopDragEnded: handleStopDragEnded,
                onStopTap: handleStopTap,
                isDraggingHandle: $isDraggingHandle,
                pinchGesture: pinchGesture,
                panGesture: panGesture
            )

            Spacer()

            // Controls (only show if not editing or if regular width)
            if !viewModel.isEditingStop || !isCompactWidth {
                controlButtons
            }
        }
    }

    @ViewBuilder
    private func horizontalGradientLayout(geometry: GradientLayoutGeometry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            // Gradient strip with stops
            GradientStripView(
                viewModel: viewModel,
                geometry: geometry,
                onStopDragChanged: handleStopDragChanged,
                onStopDragEnded: handleStopDragEnded,
                onStopTap: handleStopTap,
                isDraggingHandle: $isDraggingHandle,
                pinchGesture: pinchGesture,
                panGesture: panGesture
            )

            Spacer()

            // Controls (only show if not editing or if regular width)
            if !viewModel.isEditingStop || !isCompactWidth {
                HStack {
                    controlButtons
                    Spacer()
                }
            }
        }
    }

    // MARK: - Editor View

    private var editorView: some View {
        ColorStopEditorView(viewModel: viewModel.colorStopViewModel)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        VStack(spacing: 20) {
            Button {
                viewModel.exportGradient()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title)
            }

            Button {
                viewModel.addTapped()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.title)
            }
        }
    }

    // MARK: - Handle Interactions

    private func handleStopDragChanged(_ handleVM: DragHandleViewModel, coord: CGFloat) {
        guard let geom = currentGeometry else { return }
        let newPosition = geom.gradientPosition(from: coord)
        viewModel.update(colorStopId: handleVM.id, position: newPosition)
    }

    private func handleStopDragEnded(_ handleVM: DragHandleViewModel) {
        // Cleanup if needed
    }

    private func handleStopTap(_ handleVM: DragHandleViewModel) {
        viewModel.stopTapped(handleVM.id)
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .updating($magnification) { value, state, _ in
                state = value
            }
            .onChanged { [self] value in
                let newZoom = baseZoom * value
                activeZoom = max(1.0, min(4.0, newZoom))

                // Reset pan if zoom is back to 100%
                if activeZoom == 1.0 {
                    activePan = 0.0
                }
            }
            .onEnded { [self] value in
                let newZoom = baseZoom * value
                viewModel.updateZoom(newZoom)
                activeZoom = viewModel.zoomLevel
                baseZoom = viewModel.zoomLevel
            }
    }

    private var panGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { [self] value in
                guard !isDraggingHandle else { return }
                guard activeZoom > 1.0 else { return }
                guard let geom = currentGeometry else { return }

                let translation = geom.orientation == .vertical ? value.translation.height : value.translation.width
                let panChange = -translation / geom.stripLength
                activePan = max(0.0, min(1.0, basePan + panChange))
            }
            .onEnded { [self] value in
                guard !isDraggingHandle else { return }
                guard activeZoom > 1.0 else { return }

                viewModel.updatePan(activePan)
                basePan = activePan
            }
    }

}

#Preview {
    GradientEditView(viewModel: GradientEditViewModel(scheme: .wakeIsland))
}
