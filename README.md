# GradientEditor

A SwiftUI package for editing color gradients with an intuitive, gesture-driven interface.

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2018+%20%7C%20visionOS%202+%20%7C%20macOS%2015+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features

- ✨ **Interactive Gradient Editing** - Drag color stops, adjust positions, modify colors
- 🎨 **Single & Dual-Color Stops** - Create smooth gradients or hard color transitions
- 🔍 **Zoom & Pan** - Zoom up to 4x for precise stop positioning
- 📱 **Adaptive Layout** - Automatic adaptation to device size and orientation
- ♿️ **Fully Accessible** - Complete VoiceOver and Dynamic Type support
- 🌐 **Localized** - Ready for internationalization with string catalog
- 🧪 **Thoroughly Tested** - 133 tests with 100% pass rate
- 🎯 **Swift 6 Strict Concurrency** - Thread-safe with `@MainActor` isolation

## Quick Start

### Installation

Add GradientEditor to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/GradientEditor.git", from: "1.0.0")
]
```

### Basic Usage

```swift
import SwiftUI
import GradientEditor

struct ContentView: View {
    @State private var viewModel: GradientEditViewModel

    init() {
        // Create view model with a preset gradient
        viewModel = GradientEditViewModel(scheme: .wakeIsland) { result in
            switch result {
            case .saved(let scheme):
                print("Gradient '\(scheme.name)' saved with \(scheme.colorMap.stops.count) stops")
                // Save the gradient scheme to your app's storage
            case .cancelled:
                print("Editing cancelled")
            }
        }
    }

    var body: some View {
        GradientEditView(viewModel: viewModel)
    }
}
```

## Key Components

### GradientEditView

The main SwiftUI view for gradient editing. Provides:
- Interactive gradient preview with draggable color stops
- Zoom (1x-4x) and pan gestures for precise editing
- Adaptive layout for compact and regular size classes
- Built-in controls for adding/exporting gradients

### GradientEditViewModel

The view model managing gradient editing state:
- Color stop management (add, delete, duplicate, modify)
- Zoom and pan state
- Selection and editing state
- Completion callbacks for save/cancel

### Data Models

- **`GradientColorScheme`** - A named gradient with metadata
- **`ColorMap`** - Collection of color stops defining a gradient
- **`ColorStop`** - Single color or dual-color at a position (0.0-1.0)
- **`ColorStopType`** - `.single(CGColor)` or `.dual(CGColor, CGColor)`

## Example: Custom Gradient

```swift
// Create a custom gradient
let customGradient = GradientColorScheme(
    name: "Ocean Depths",
    description: "Deep blues fading to black",
    colorMap: ColorMap(stops: [
        ColorStop(position: 0.0, type: .single(.blue)),
        ColorStop(position: 0.7, type: .dual(.cyan, .black)),
        ColorStop(position: 1.0, type: .single(.black))
    ])
)

// Use it in the editor
let viewModel = GradientEditViewModel(scheme: customGradient) { result in
    // Handle result
}
```

## Built-in Presets

GradientEditor includes several preset gradients:

- **Black & White** - Simple two-color gradient
- **Wake Island** - Tropical island colors
- **Neon Ripples** - Abstract neon lines
- **Apple ][ River** - Retro computing green
- **Electoral Map** - Red vs. blue
- **Topographic** - Map-inspired contours

Access all presets: `GradientColorScheme.allPresets`

## Gestures

### Gradient Preview
- **Tap** - Select a color stop for editing
- **Drag** - Move a color stop along the gradient
- **Pinch** - Zoom in/out (1x to 4x)
- **Two-finger drag** - Pan when zoomed in

### Color Stop Editor
- **Color Picker** - Change stop colors
- **Position Field** - Enter precise position value
- **Type Picker** - Switch between single/dual color
- **Prev/Next** - Navigate between stops
- **Duplicate** - Create a copy at midpoint
- **Delete** - Remove stop (minimum 2 stops)

## Adaptive Layout

### Compact Width (iPhone Portrait)
- Editor appears in a modal sheet
- Controls hidden during editing
- `.presentationDetents([.medium, .large])`

### Regular Width (iPad, iPhone Landscape)
- Side-by-side layout
- Editor panel on right (300pt)
- Controls remain visible

## Accessibility

- **VoiceOver Labels** - All interactive elements labeled
- **Accessibility Hints** - Contextual action descriptions
- **Dynamic Type** - Scales with text size preferences
- **Accessibility Identifiers** - For UI testing
- **Gesture Accessibility** - VoiceOver-compatible actions

## Localization

All user-facing strings are localized via `Localizable.xcstrings`. The package is ready for additional language translations.

## Export & Import

```swift
// Export to JSON
let jsonData = try gradientScheme.toJSON()
let jsonString = String(data: jsonData, encoding: .utf8)

// Import from JSON
let importedScheme = try GradientColorScheme.from(json: jsonData)
```

## Requirements

- iOS 18.0+ / visionOS 2.0+ / macOS 15.0+
- Swift 6.2+
- Xcode 16.0+

## Architecture

- **MVVM Pattern** - Clear separation of concerns
- **SwiftUI** - Modern declarative UI
- **@Observable** - State management
- **Combine** - Action publishers for view model communication
- **Swift 6 Strict Concurrency** - Thread-safe with `@MainActor`

## Testing

Run tests with:

```bash
swift test
```

**Test Coverage:**
- 133 tests across 8 suites
- Models, view models, geometry, views, integration
- 100% pass rate
- ~93% coverage of business logic

## Documentation

Full DocC documentation is available. Build documentation in Xcode:

1. Product → Build Documentation
2. View in Documentation Viewer

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Created by Joshua Sullivan

---

Made with ❤️ using SwiftUI

