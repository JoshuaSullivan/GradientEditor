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
                .accessibilityLabel(AccessibilityLabels.stopEditorPrev)
                .accessibilityHint(AccessibilityHints.stopEditorPrev)
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorPrev)

                Spacer()

                Button(action: {
                    viewModel.closeTapped()
                }, label: {
                    Image(systemName: "xmark")
                })
                .accessibilityLabel(AccessibilityLabels.stopEditorClose)
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorClose)

                Spacer()

                Button(action: {
                    viewModel.nextTapped()
                }, label: {
                    Image(systemName: "chevron.forward")
                        .font(.title2)
                })
                .accessibilityLabel(AccessibilityLabels.stopEditorNext)
                .accessibilityHint(AccessibilityHints.stopEditorNext)
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorNext)
            }
            .padding(.bottom)
            HStack {
                Spacer()
                Text(.editorPositionLabel)
                TextField("Position", value: $viewModel.position, formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorPosition)
                Spacer()
            }

            Picker(selection: $viewModel.isSingleColorStop) {
                Text(.colorStopTypeSingle).tag(true)
                Text(.colorStopTypeDual).tag(false)
            } label: {
                Text(.editorPickerTitle)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorTypePicker)

            if viewModel.isSingleColorStop {
                ColorPicker(selection: $viewModel.firstcolor) {
                    Text(.editorColorLabel)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorColorPicker)
            } else {
                ColorPicker(selection:  $viewModel.firstcolor) {
                    Text(.editorFirstColorLabel)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorFirstColorPicker)

                ColorPicker(selection: $viewModel.secondColor) {
                    Text(.editorSecondColorLabel)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorSecondColorPicker)
            }

            HStack(spacing: 20) {
                Button {
                    viewModel.duplicateTapped()
                } label: {
                    Text(.editorDuplicateButton)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(AccessibilityLabels.stopEditorDuplicate)
                .accessibilityHint(AccessibilityHints.stopEditorDuplicate)
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorDuplicate)

                Button(role: .destructive) {
                    viewModel.deleteTapped()
                } label: {
                    Text(.editorDeleteButton)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canDelete)
                .accessibilityLabel(AccessibilityLabels.stopEditorDelete)
                .accessibilityHint(AccessibilityHints.stopEditorDelete)
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorDelete)
            }

            Spacer()
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityIdentifiers.stopEditor)
    }
}

#Preview {
    ColorStopEditorView(viewModel: ColorStopEditorViewModel(colorStop: ColorStop(type: .single(.red))))
}
