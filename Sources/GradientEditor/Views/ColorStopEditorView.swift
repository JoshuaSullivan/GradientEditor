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
                Text(.editorPositionLabel)
                TextField("Position", value: $viewModel.position, formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                Spacer()
            }
            Picker(selection: $viewModel.isSingleColorStop) {
                Text(.colorStopTypeSingle).tag(true)
                Text(.colorStopTypeDual).tag(false)
            } label: {
                Text(.editorPickerTitle)
            }
            .pickerStyle(.segmented)

            if viewModel.isSingleColorStop {
                ColorPicker(selection: $viewModel.firstcolor) {
                    Text(.editorColorLabel)
                }
            } else {
                ColorPicker(selection:  $viewModel.firstcolor) {
                    Text(.editorFirstColorLabel)
                }
                ColorPicker(selection: $viewModel.secondColor) {
                    Text(.editorSecondColorLabel)
                }
            }
            HStack(spacing: 20) {
                Button {
                    viewModel.duplicateTapped()
                } label: {
                    Text(.editorDuplicateButton)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    viewModel.deleteTapped()
                } label: {
                    Text(.editorDeleteButton)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canDelete)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ColorStopEditorView(viewModel: ColorStopEditorViewModel(colorStop: ColorStop(type: .single(.red))))
}
