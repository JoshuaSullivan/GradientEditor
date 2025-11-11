//
//  ColorProvider.swift
//  GradientEditor
//
//  Created by Claude on 11/11/25.
//

import SwiftUI

// MARK: - ColorEditContext

/// Context information provided to a custom color provider when requesting a color selection view.
///
/// This structure contains information about which color is being edited, whether it's part of a
/// single or dual color stop, and the appropriate accessibility label for the color selection UI.
public struct ColorEditContext: Sendable {

    // MARK: - ColorIndex

    /// Identifies which color in a color stop is being edited.
    public enum ColorIndex: Sendable {
        /// The first (or only) color in a color stop.
        case first

        /// The second color in a dual color stop.
        case second
    }

    // MARK: - Properties

    /// Indicates which color is being edited (first or second).
    public let colorIndex: ColorIndex

    /// Whether this is a single color stop (true) or dual color stop (false).
    public let isSingleColorStop: Bool

    /// A localized accessibility label appropriate for the color being edited.
    ///
    /// For example: "Color", "First Color", or "Second Color" in the user's language.
    public let accessibilityLabel: String

    // MARK: - Initialization

    /// Creates a new color edit context.
    ///
    /// - Parameters:
    ///   - colorIndex: Which color is being edited (first or second).
    ///   - isSingleColorStop: Whether this is a single or dual color stop.
    ///   - accessibilityLabel: Localized accessibility label for the color.
    public init(
        colorIndex: ColorIndex,
        isSingleColorStop: Bool,
        accessibilityLabel: String
    ) {
        self.colorIndex = colorIndex
        self.isSingleColorStop = isSingleColorStop
        self.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - ColorProvider

/// A protocol that enables custom color selection UI in the gradient editor.
///
/// Implement this protocol to provide your own color picker interface to replace the default
/// SwiftUI `ColorPicker`. The gradient editor will call ``colorView(currentColor:onColorChange:context:)``
/// to obtain a view for color selection, passing the current color value and a callback closure
/// for reporting color changes.
///
/// ## Example Implementation
///
/// ```swift
/// struct CustomColorProvider: ColorProvider {
///     func colorView(
///         currentColor: CGColor,
///         onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
///         context: ColorEditContext
///     ) -> AnyView {
///         AnyView(
///             CustomColorPickerView(
///                 initialColor: currentColor,
///                 onChange: onColorChange
///             )
///             .accessibilityLabel(context.accessibilityLabel)
///         )
///     }
/// }
/// ```
///
/// ## Threading
///
/// This protocol is `@MainActor` isolated because it returns SwiftUI views, which must be
/// created on the main thread.
///
/// ## Accessibility
///
/// Custom implementations should use the `accessibilityLabel` from the provided ``ColorEditContext``
/// to ensure proper accessibility support. Additional accessibility features such as hints and
/// values are recommended but not required.
@MainActor
public protocol ColorProvider {

    /// Creates a view for selecting a color.
    ///
    /// This method is called when the gradient editor needs to display color selection UI.
    /// The implementation should return a SwiftUI view that allows the user to choose a color,
    /// and call the `onColorChange` closure whenever the selected color changes.
    ///
    /// - Parameters:
    ///   - currentColor: The current color value to display in the picker.
    ///   - onColorChange: A closure to call when the user selects a new color.
    ///                    Must be called on the main actor.
    ///   - context: Additional context about which color is being edited and accessibility information.
    ///
    /// - Returns: A SwiftUI view that provides color selection UI.
    ///
    /// - Note: The returned view should handle its own layout and sizing appropriately for the
    ///         containing view hierarchy.
    func colorView(
        currentColor: CGColor,
        onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
        context: ColorEditContext
    ) -> AnyView
}
