import SwiftUI

struct ColorStopEditorView: View {

    @Bindable var viewModel: ColorStopEditorViewModel
    let gradientStops: [ColorStop]

    @Environment(\.verticalSizeClass) private var verticalSizeClass

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
                // Navigation buttons grouped on leading edge
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.prevTapped()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .font(.title2)
                    })
                    .accessibilityLabel(AccessibilityLabels.stopEditorPrev)
                    .accessibilityHint(AccessibilityHints.stopEditorPrev)
                    .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorPrev)

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

                Spacer()

                // Close button on trailing edge
                Button(action: {
                    viewModel.closeTapped()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                })
                .accessibilityLabel(AccessibilityLabels.stopEditorClose)
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorClose)
            }
            .padding(.bottom)
            HStack {
                Text(LocalizedString.editorPositionLabel)
                TextField("Position", value: $viewModel.position, formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorPosition)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        viewModel.duplicateTapped()
                    } label: {
                        Image(systemName: "plus.square.on.square")
                            .font(.title2)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel(AccessibilityLabels.stopEditorDuplicate)
                    .accessibilityHint(AccessibilityHints.stopEditorDuplicate)
                    .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorDuplicate)

                    Button(role: .destructive) {
                        viewModel.deleteTapped()
                    } label: {
                        Image(systemName: "trash")
                            .font(.title2)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .disabled(!viewModel.canDelete)
                    .accessibilityLabel(AccessibilityLabels.stopEditorDelete)
                    .accessibilityHint(AccessibilityHints.stopEditorDelete)
                    .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorDelete)
                }
            }

            Picker(selection: $viewModel.isSingleColorStop) {
                Text(LocalizedString.colorStopTypeSingle).tag(true)
                Text(LocalizedString.colorStopTypeDual).tag(false)
            } label: {
                Text(LocalizedString.editorPickerTitle)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorTypePicker)

            if viewModel.isSingleColorStop {
                ColorPicker(selection: $viewModel.firstcolor) {
                    Text(LocalizedString.editorColorLabel)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorColorPicker)
            } else {
                ColorPicker(selection:  $viewModel.firstcolor) {
                    Text(LocalizedString.editorFirstColorLabel)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorFirstColorPicker)

                ColorPicker(selection: $viewModel.secondColor) {
                    Text(LocalizedString.editorSecondColorLabel)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.stopEditorSecondColorPicker)
            }

            Spacer()

            // Gradient preview at bottom
            gradientPreview
                .padding(.vertical, 4)
        }
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityIdentifiers.stopEditor)
    }

    // MARK: - Gradient Preview

    private var gradientPreview: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(gradientFill)
                .frame(height: 40)
                .cornerRadius(8)
                .overlay(
                    // Position indicator line
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 1, height: 56) // 40pt strip + 8pt above + 8pt below
                        .offset(x: geometry.size.width * viewModel.position - geometry.size.width / 2, y: 0)
                )
        }
        .frame(height: 40)
    }

    private var gradientFill: LinearGradient {
        var stops: [Gradient.Stop] = []

        for colorStop in gradientStops {
            switch colorStop.type {
            case .single(let color):
                stops.append(Gradient.Stop(color: Color(cgColor: color), location: colorStop.position))
            case .dual(let colorA, let colorB):
                stops.append(Gradient.Stop(color: Color(cgColor: colorA), location: colorStop.position))
                stops.append(Gradient.Stop(color: Color(cgColor: colorB), location: colorStop.position))
            }
        }

        return LinearGradient(stops: stops, startPoint: .leading, endPoint: .trailing)
    }
}

#Preview {
    ColorStopEditorView(
        viewModel: ColorStopEditorViewModel(colorStop: ColorStop(type: .single(.red))),
        gradientStops: [
            ColorStop(position: 0.0, type: .single(.red)),
            ColorStop(position: 0.5, type: .dual(.blue, .green)),
            ColorStop(position: 1.0, type: .single(.purple))
        ]
    )
}
