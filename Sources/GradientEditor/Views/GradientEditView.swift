import SwiftUI

/// The main gradient editing view.
///
/// `GradientEditView` provides a complete UI for editing gradients, including:
/// - Interactive gradient preview with zoom and pan
/// - Draggable color stop handles
/// - Color stop editor panel (adaptive to screen size)
/// - Control buttons for adding stops and exporting
///
/// The view automatically adapts its layout based on size class (compact vs. regular width).
///
/// ## Topics
///
/// ### Creating the View
/// - ``init(viewModel:)``
///
/// ## Example
/// ```swift
/// struct MyGradientEditor: View {
///     @State private var viewModel: GradientEditViewModel
///
///     init() {
///         viewModel = GradientEditViewModel(scheme: .wakeIsland) { result in
///             switch result {
///             case .saved(let scheme):
///                 print("Saved: \(scheme.name)")
///             case .cancelled:
///                 print("Cancelled")
///             }
///         }
///     }
///
///     var body: some View {
///         GradientEditView(viewModel: viewModel)
///     }
/// }
/// ```
public struct GradientEditView: View {

    @Bindable public var viewModel: GradientEditViewModel

    @GestureState private var magnification: CGFloat = 1.0
    @State private var baseZoom: CGFloat
    @State private var basePan: CGFloat
    @State private var showEditorSheet = false
    @State private var showMetadataEditor = false
    @State private var currentGeometry: GradientLayoutGeometry?
    @State private var isDraggingHandle = false

    // Active values during gestures (for immediate visual feedback)
    @State private var activeZoom: CGFloat
    @State private var activePan: CGFloat

    // Temporary state for metadata editing
    @State private var editingName: String = ""
    @State private var editingDescription: String = ""

    @Environment(\.self) private var environment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Initializer
    /// Creates a gradient edit view.
    ///
    /// - Parameter viewModel: The view model managing the gradient editing state.
    ///
    /// ## Example
    /// ```swift
    /// let viewModel = GradientEditViewModel(scheme: .wakeIsland)
    /// let editView = GradientEditView(viewModel: viewModel)
    /// ```
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
        .sheet(isPresented: $showMetadataEditor) {
            SchemeMetadataEditorView(
                name: $editingName,
                description: $editingDescription,
                onSave: {
                    viewModel.updateSchemeMetadata(name: editingName, description: editingDescription)
                    showMetadataEditor = false
                },
                onCancel: {
                    showMetadataEditor = false
                }
            )
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
                controlButtons(orientation: geometry.orientation)
            }
        }
    }

    @ViewBuilder
    private func horizontalGradientLayout(geometry: GradientLayoutGeometry) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Controls at top in landscape (only show if not editing or if regular width)
            if !viewModel.isEditingStop || !isCompactWidth {
                HStack {
                    Spacer()
                    controlButtons(orientation: geometry.orientation)
                    Spacer()
                }
            }

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
        }
    }

    // MARK: - Editor View

    private var editorView: some View {
        ColorStopEditorView(
            viewModel: viewModel.colorStopViewModel,
            gradientStops: viewModel.colorStops
        )
    }

    // MARK: - Control Buttons

    @ViewBuilder
    private func controlButtons(orientation: GradientLayoutGeometry.Orientation) -> some View {
        // In horizontal (landscape) mode, buttons are arranged horizontally
        // In vertical (portrait) mode, buttons are arranged vertically
        Group {
            if orientation == .horizontal {
                HStack(spacing: 20) {
                    settingsButton
                    addStopButton
                }
            } else {
                VStack(spacing: 20) {
                    settingsButton
                    addStopButton
                }
            }
        }
    }

    private var settingsButton: some View {
        Button {
            // Initialize editing state with current values
            editingName = viewModel.scheme.name
            editingDescription = viewModel.scheme.description
            showMetadataEditor = true
        } label: {
            Image(systemName: "gearshape")
                .font(.title)
        }
        .accessibilityLabel(AccessibilityLabels.settingsButton)
        .accessibilityHint(AccessibilityHints.settingsButton)
        .accessibilityIdentifier(AccessibilityIdentifiers.settingsButton)
    }

    private var addStopButton: some View {
        Button {
            viewModel.addTapped()
        } label: {
            Image(systemName: "plus.circle")
                .font(.title)
        }
        .accessibilityLabel(AccessibilityLabels.addStopButton)
        .accessibilityHint(AccessibilityHints.addStopButton)
        .accessibilityIdentifier(AccessibilityIdentifiers.addStopButton)
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
