import SwiftUI

struct ColorStopEditorView: View {
    
    @Bindable var viewModel: ColorStopEditorViewModel
    
    private let formatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 3
        nf.maximumFractionDigits = 3
        nf.minimumIntegerDigits = 1
        nf.allowsFloats = true
        nf.alwaysShowsDecimalSeparator = true
        return nf
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.prevTapped()
                }, label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                })
                Spacer()
                Button(action: {
                    viewModel.closeTapped()
                }, label: {
                    Image(systemName: "xmark")
                })
                Spacer()
                Button(action: {
                    viewModel.nextTapped()
                }, label: {
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                })
            }
            .padding(.bottom)
            HStack {
                Spacer()
                Text("Position:")
                TextField("Position", value: $viewModel.position, formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                Spacer()
            }
            Picker("Color Stop Type", selection: $viewModel.isSingleColorStop) {
                Text("Single").tag(true)
                Text("Dual").tag(false)
            }
            .pickerStyle(.segmented)
            
            if viewModel.isSingleColorStop {
                ColorPicker("Color", selection: $viewModel.firstcolor)
            } else {
                ColorPicker("First Color", selection:  $viewModel.firstcolor)
                ColorPicker("Second Color", selection: $viewModel.secondColor)
            }
            Button("Delete", role: .destructive) {
                viewModel.deleteTapped()
            }
            .buttonStyle(BorderlessButtonStyle())
            .disabled(!viewModel.canDelete)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ColorStopEditorView(viewModel: ColorStopEditorViewModel(colorStop: ColorStop(type: .single(.red))))
}
