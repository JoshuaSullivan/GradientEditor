import SwiftUI

/// Displays the gradient strip with draggable color stop handles.
struct GradientStripView: View {
    let viewModel: GradientEditViewModel
    let geometry: GradientLayoutGeometry
    let onStopDrag: (DragHandleViewModel, CGFloat) -> Void
    let onStopTap: (DragHandleViewModel) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Gradient rectangle
            Rectangle()
                .fill(viewModel.gradientFill)
                .frame(
                    width: geometry.orientation == .vertical ? geometry.stripWidth : geometry.stripLength,
                    height: geometry.orientation == .vertical ? geometry.stripLength : geometry.stripWidth
                )

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
                    DragHandle(viewModel: handleVM)
                        .offset(offset)
                        .gesture(stopDragGesture(for: handleVM))
                        .gesture(stopTapGesture(for: handleVM))
                }
            }
        }
    }

    // MARK: - Helper Computed Properties

    private var selectedStopViewPosition: CGFloat? {
        guard viewModel.isEditingStop else { return nil }
        return geometry.viewCoordinate(for: viewModel.editPosition)
    }

    // MARK: - Gestures

    private func stopDragGesture(for handleVM: DragHandleViewModel) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let coord: CGFloat = geometry.orientation == .vertical
                    ? value.location.y
                    : value.location.x
                onStopDrag(handleVM, coord)
            }
    }

    private func stopTapGesture(for handleVM: DragHandleViewModel) -> some Gesture {
        TapGesture()
            .onEnded {
                onStopTap(handleVM)
            }
    }
}
