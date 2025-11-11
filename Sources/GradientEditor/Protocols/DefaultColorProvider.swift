//
//  DefaultColorProvider.swift
//  GradientEditor
//
//  Created by Claude on 11/11/25.
//

import SwiftUI

/// The default color provider implementation that uses SwiftUI's native `ColorPicker`.
///
/// This provider maintains the standard gradient editor color selection behavior using
/// the system color picker. It automatically handles color value updates and accessibility.
///
/// You generally don't need to instantiate this directly, as it's used automatically when
/// no custom provider is specified.
@MainActor
public struct DefaultColorProvider: ColorProvider {

    /// Creates a new default color provider.
    public init() {}

    public func colorView(
        currentColor: CGColor,
        onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
        context: ColorEditContext
    ) -> AnyView {
        AnyView(
            DefaultColorPickerView(
                currentColor: currentColor,
                onColorChange: onColorChange,
                context: context
            )
        )
    }
}

// MARK: - DefaultColorPickerView

/// Internal view that wraps SwiftUI's ColorPicker with callback-based color updates.
private struct DefaultColorPickerView: View {

    let onColorChange: @MainActor @Sendable (CGColor) -> Void
    let context: ColorEditContext

    @State private var selectedColor: CGColor

    init(
        currentColor: CGColor,
        onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
        context: ColorEditContext
    ) {
        self.onColorChange = onColorChange
        self.context = context
        self._selectedColor = State(initialValue: currentColor)
    }

    var body: some View {
        ColorPicker(selection: $selectedColor) {
            Text(context.accessibilityLabel)
        }
        .onChange(of: selectedColor) { _, newValue in
            onColorChange(newValue)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    // MARK: - Accessibility

    private var accessibilityIdentifier: String {
        if context.isSingleColorStop {
            return AccessibilityIdentifiers.stopEditorColorPicker
        } else {
            switch context.colorIndex {
            case .first:
                return AccessibilityIdentifiers.stopEditorFirstColorPicker
            case .second:
                return AccessibilityIdentifiers.stopEditorSecondColorPicker
            }
        }
    }
}
