/// # GradientEditor
///
/// A SwiftUI framework for creating and editing complex gradients with multiple color stops.
///
/// ## Overview
///
/// GradientEditor provides a comprehensive, user-friendly interface for creating and editing
/// gradients with multiple color stops. The framework supports both single and dual-color stops,
/// allowing for sharp transitions and complex color combinations. It includes features like
/// zoom and pan for precise editing, color stop management, and customizable color selection UI.
///
/// ## Getting Started
///
/// The primary entry point for using GradientEditor is the ``GradientEditView``, which provides
/// a complete gradient editing interface. For SwiftUI applications, you can embed this view
/// directly in your view hierarchy:
///
/// ```swift
/// import SwiftUI
/// import GradientEditor
///
/// struct ContentView: View {
///     @State private var scheme = GradientColorScheme.wakeIsland
///
///     var body: some View {
///         GradientEditView(
///             viewModel: GradientEditViewModel(scheme: scheme) { result in
///                 switch result {
///                 case .saved(let updatedScheme):
///                     print("Saved: \(updatedScheme.name)")
///                 case .cancelled:
///                     print("Editing cancelled")
///                 }
///             }
///         )
///     }
/// }
/// ```
///
/// For UIKit applications, use ``GradientEditorViewController``:
///
/// ```swift
/// import UIKit
/// import GradientEditor
///
/// class MyViewController: UIViewController {
///     func showGradientEditor() {
///         let scheme = GradientColorScheme.wakeIsland
///         let editor = GradientEditorViewController(scheme: scheme) { result in
///             // Handle result
///         }
///         present(editor, animated: true)
///     }
/// }
/// ```
///
/// ## Key Features
///
/// ### Multiple Color Stops
///
/// Create gradients with any number of color stops. Each stop can be:
/// - **Single color**: A solid color at that position
/// - **Dual color**: Two colors for sharp transitions
///
/// ### Zoom and Pan
///
/// Fine-tune gradient positioning with zoom (1x-4x) and pan controls for precise editing
/// of closely-spaced color stops.
///
/// ### Color Stop Management
///
/// - Add new stops at any position
/// - Drag stops to reposition them
/// - Delete stops (minimum 2 required)
/// - Duplicate stops to maintain color combinations
/// - Edit stop properties (position, color, type)
///
/// ### Custom Color Selection
///
/// Replace the default color picker with your own custom UI by implementing the ``ColorProvider``
/// protocol. This enables:
/// - Brand-specific color palettes
/// - Specialized color selection interfaces
/// - Integration with existing design systems
/// - Custom accessibility features
///
/// Example:
///
/// ```swift
/// struct MyCustomColorProvider: ColorProvider {
///     func colorView(
///         currentColor: CGColor,
///         onColorChange: @escaping @MainActor @Sendable (CGColor) -> Void,
///         context: ColorEditContext
///     ) -> AnyView {
///         AnyView(MyCustomColorPicker(
///             color: currentColor,
///             onChange: onColorChange
///         ))
///     }
/// }
///
/// let viewModel = GradientEditViewModel(
///     scheme: myScheme,
///     colorProvider: MyCustomColorProvider()
/// )
/// ```
///
/// ## Architecture
///
/// GradientEditor follows the MVVM (Model-View-ViewModel) pattern:
///
/// ### Models
///
/// - ``GradientColorScheme``: Represents a named gradient with metadata
/// - ``ColorMap``: Collection of color stops that define the gradient
/// - ``ColorStop``: Individual stop with position and color(s)
/// - ``ColorStopType``: Single or dual color configuration
///
/// ### View Models
///
/// - ``GradientEditViewModel``: Main view model for gradient editing
/// - ``ColorStopEditorViewModel``: Manages individual color stop editing
/// - ``DragHandleViewModel``: Manages drag handle state
///
/// ### Views
///
/// - ``GradientEditView``: Complete SwiftUI gradient editor
/// - SwiftUI components for color stop editing and visualization
///
/// ### Platform Integration
///
/// - ``GradientEditorViewController``: UIKit integration
/// - ``AppKitGradientEditorViewController``: AppKit integration (macOS)
///
/// ## Accessibility
///
/// GradientEditor is built with accessibility in mind:
///
/// - Full VoiceOver support
/// - Dynamic Type support
/// - Semantic colors that adapt to light/dark mode
/// - Descriptive accessibility labels and hints
/// - Keyboard navigation support (macOS)
///
/// ## Topics
///
/// ### Essentials
///
/// - ``GradientEditView``
/// - ``GradientEditViewModel``
/// - ``GradientColorScheme``
///
/// ### Models
///
/// - ``ColorMap``
/// - ``ColorStop``
/// - ``ColorStopType``
/// - ``GradientEditorResult``
///
/// ### Customization
///
/// - ``ColorProvider``
/// - ``ColorEditContext``
/// - ``DefaultColorProvider``
///
/// ### Platform Integration
///
/// - ``GradientEditorViewController``
/// - ``GradientEditorDelegate``
/// - ``AppKitGradientEditorViewController``
/// - ``AppKitGradientEditorDelegate``
///
/// ### View Models
///
/// - ``ColorStopEditorViewModel``
/// - ``DragHandleViewModel``
