//
//  HueSliderColorProvider.swift
//  GradientEditorExample
//
//  Created by Claude on 11/11/25.
//

import SwiftUI
import GradientEditor

/// A custom color provider that uses a simple hue slider for color selection.
///
/// This provider demonstrates how to implement the ColorProvider protocol with
/// a custom UI. It displays a square color preview and allows color selection
/// via a hue slider (0-1) with saturation and brightness fixed at 1.0.
struct HueSliderColorProvider: ColorProvider {

    func colorView(
        currentColor: CGColor,
        onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
        context: ColorEditContext
    ) -> AnyView {
        AnyView(
            HueSliderView(
                initialColor: currentColor,
                onColorChange: onColorChange,
                accessibilityLabel: context.accessibilityLabel
            )
        )
    }
}

// MARK: - HueSliderView

/// The custom color selection view using a hue slider.
private struct HueSliderView: View {

    let onColorChange: @MainActor @Sendable (CGColor) -> Void
    let accessibilityLabel: String

    @State private var hue: Double
    @State private var pendingColor: CGColor
    @State private var isPresented = false
    @Environment(\.colorScheme) private var colorScheme

    init(
        initialColor: CGColor,
        onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
        accessibilityLabel: String
    ) {
        self.onColorChange = onColorChange
        self.accessibilityLabel = accessibilityLabel

        // Extract hue from initial color
        let color = Color(cgColor: initialColor)
        let uiColor = UIColor(color)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

        _hue = State(initialValue: Double(h))
        _pendingColor = State(initialValue: initialColor)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Square color preview
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(cgColor: pendingColor))
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                )
                .accessibilityLabel("Current \(accessibilityLabel.lowercased())")

            // Edit button
            Button {
                isPresented = true
            } label: {
                HStack {
                    Text("Edit")
                    Image(systemName: "slider.horizontal.3")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Edit \(accessibilityLabel.lowercased())")
        }
        .padding(.horizontal, 4)
        .sheet(isPresented: $isPresented) {
            HueSliderSheet(
                hue: $hue,
                onSave: {
                    let newColor = createColor(from: hue)
                    pendingColor = newColor
                    onColorChange(newColor)
                    isPresented = false
                },
                onCancel: {
                    isPresented = false
                },
                accessibilityLabel: accessibilityLabel
            )
            .presentationDetents([.medium])
        }
    }

    private func createColor(from hue: Double) -> CGColor {
        UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
    }
}

// MARK: - HueSliderSheet

/// The sheet view containing the hue slider and controls.
private struct HueSliderSheet: View {

    @Binding var hue: Double
    let onSave: () -> Void
    let onCancel: () -> Void
    let accessibilityLabel: String

    @State private var localHue: Double

    init(
        hue: Binding<Double>,
        onSave: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        accessibilityLabel: String
    ) {
        self._hue = hue
        self.onSave = onSave
        self.onCancel = onCancel
        self.accessibilityLabel = accessibilityLabel
        self._localHue = State(initialValue: hue.wrappedValue)
    }

    var currentColor: Color {
        Color(UIColor(hue: localHue, saturation: 1.0, brightness: 1.0, alpha: 1.0))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Large color preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentColor)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .accessibilityLabel("\(accessibilityLabel) preview")

                // Hue slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hue: \(Int(localHue * 360))°")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Slider(value: $localHue, in: 0...1)
                        .accessibilityLabel("Hue slider")
                        .accessibilityValue("\(Int(localHue * 360)) degrees")
                }
                .padding(.horizontal)

                Spacer()

                // Buttons
                HStack(spacing: 12) {
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)

                    Button("Save") {
                        hue = localHue
                        onSave()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Select \(accessibilityLabel)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("HueSliderColorProvider") {
    struct PreviewContainer: View {
        @State private var color: CGColor = .blue

        var body: some View {
            VStack(spacing: 20) {
                Text("Custom Color Provider Demo")
                    .font(.headline)

                HueSliderColorProvider().colorView(
                    currentColor: color,
                    onColorChange: { newColor in
                        color = newColor
                    },
                    context: ColorEditContext(
                        colorIndex: .first,
                        isSingleColorStop: true,
                        accessibilityLabel: "Color"
                    )
                )
                .padding()

                Rectangle()
                    .fill(Color(cgColor: color))
                    .frame(height: 100)
                    .cornerRadius(8)
                    .padding()
            }
        }
    }

    return PreviewContainer()
}
