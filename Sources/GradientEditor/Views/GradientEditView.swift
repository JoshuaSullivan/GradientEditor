import SwiftUI

struct GradientEditView: View {

    @Bindable var viewModel: GradientEditViewModel

    @State private var selectedColor: CGColor = .green
    @State private var viewSize: CGSize = .zero
    @GestureState private var magnification: CGFloat = 1.0
    @GestureState private var panTranslation: CGSize = .zero
    @State private var baseZoom: CGFloat = 1.0
    @State private var basePan: CGFloat = 0.0
    @State private var showEditorSheet = false

    @Environment(\.self) private var environment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Computed layout geometry based on current view size and zoom/pan state.
    private var geometry: GradientLayoutGeometry {
        GradientLayoutGeometry(
            viewSize: viewSize,
            zoomLevel: viewModel.zoomLevel,
            panOffset: viewModel.panOffset
        )
    }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if isCompactWidth {
                    // Compact: show gradient, present editor as sheet
                    gradientView(geometry: geometry)
                        .sheet(isPresented: $showEditorSheet) {
                            editorView
                                .presentationDetents([.medium, .large])
                        }
                } else {
                    // Regular: show side-by-side
                    HStack(spacing: 0) {
                        gradientView(geometry: geometry)

                        if viewModel.isEditingStop {
                            Divider()
                            editorView
                                .frame(width: 300)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.environment = environment
                viewSize = proxy.size
            }
            .onChange(of: proxy.size) { _, newSize in
                viewSize = newSize
            }
            .onChange(of: viewModel.isEditingStop) { _, isEditing in
                if isCompactWidth {
                    showEditorSheet = isEditing
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.isEditingStop)
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
                onStopDrag: handleStopDrag,
                onStopTap: handleStopTap
            )
            .gesture(pinchGesture)
            .gesture(panGesture(geometry: geometry))

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
                onStopDrag: handleStopDrag,
                onStopTap: handleStopTap
            )
            .gesture(pinchGesture)
            .gesture(panGesture(geometry: geometry))

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

    private func handleStopDrag(_ handleVM: DragHandleViewModel, coord: CGFloat) {
        let newPosition = geometry.gradientPosition(from: coord)
        viewModel.update(colorStopId: handleVM.id, position: newPosition)
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
            .onChanged { value in
                let newZoom = baseZoom * value
                viewModel.updateZoom(newZoom)
            }
            .onEnded { value in
                baseZoom = viewModel.zoomLevel
            }
    }

    private func panGesture(geometry: GradientLayoutGeometry) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($panTranslation) { value, state, _ in
                state = value.translation
            }
            .onChanged { value in
                guard viewModel.zoomLevel > 1.0 else { return }

                let translation: CGFloat
                if geometry.orientation == .vertical {
                    translation = value.translation.height
                } else {
                    translation = value.translation.width
                }

                // Convert translation to pan offset change
                let panChange = -translation / geometry.stripLength
                let newPan = basePan + panChange
                viewModel.updatePan(newPan)
            }
            .onEnded { _ in
                basePan = viewModel.panOffset
            }
    }

}

#Preview {
    GradientEditView(viewModel: GradientEditViewModel(scheme: .wakeIsland))
}
