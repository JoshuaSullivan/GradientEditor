import SwiftUI

struct GradientEditView: View {
    
    let viewModel: GradientEditViewModel
    
    @State var selectedColor: CGColor = .green
    
    @Environment(\.self) private var environment
    
    var body: some View {
        GeometryReader { geometry in
            
            let w = geometry.size.width
            let h = geometry.size.height
            
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                    .frame(width: viewModel.isEditingStop ? 0 : (w - 200) / 2)
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(viewModel.gradientFill)
                        .frame(width: 100)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 100, height: 1)
                        .offset(y: h * viewModel.editPosition)
                        .opacity(viewModel.isEditingStop ? 0.8 : 0)
                }
                
                if viewModel.isEditingStop {
                    ColorStopEditorView(viewModel: viewModel.colorStopViewModel)
                } else {
                    ZStack(alignment: .top) {
                        ForEach(viewModel.dragHandleViewModels) { vm in
                            DragHandle(viewModel: vm)
                                .offset(y: vm.position * h)
                                .gesture(
                                    DragGesture()
                                        .onChanged({ value in
                                            let y: CGFloat = max(0, min((value.location.y / h), 1))
                                            viewModel.update(colorStopId: vm.id, position: y)
                                        })
                                )
                                .gesture(
                                    TapGesture()
                                        .onEnded({
                                            viewModel.stopTapped(vm.id)
                                        })
                                )
                        }
                    }
                    .opacity(viewModel.isEditingStop ? 0 : 1)
                    Spacer()
                    VStack {
                        Button {
                            viewModel.exportGradient()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title)
                        }
                        Spacer()
                        Button {
                            viewModel.addTapped()
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.title)
                        }
                    }
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: viewModel.isEditingStop)
        .onAppear() {
            viewModel.environment = environment
        }
    }
}

#Preview {
    GradientEditView(viewModel: GradientEditViewModel(scheme: .wakeIsland))
}
