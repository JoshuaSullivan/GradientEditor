# GradientEditor Swift Package Project

My goal for this project is to create an open-source framework Swift Package that provides an easy-to-use and powerful self-contained UI for editing gradients.

## Overview

- I've provided some starting source files from an earier attempt at this project. They are merely a guide and can be modified as the project progresses.
- I want the top-level interface for this package to be very easy to instantiate:
  - Create the top-level view model, which will have hooks for listening for completion, errors, etc.
  - Create the top-level UI using the view model and present it within the view hierarchy.
- Apple system components for functions like color picking are acceptable for a first pass, but if the component adds friction through extra clicks or a UI that doesn't fit well within the UI, we can create custom controls.
- I want the data structures defining the gradient to be sharable, so Codable conformance is important.
- I want the solution to be fully compatible with Swift 6's strict concurrency checking.

## Platform Support

### SwiftUI (Primary)
- The core UI is built with SwiftUI (`GradientEditView` + `GradientEditViewModel`)
- Works natively on iOS 18+, macOS 15+, and visionOS 2+
- Provides the most direct integration path for modern Swift apps

### UIKit Wrapper (iOS/visionOS)
- `GradientEditorViewController` provides a UIKit-native interface
- Wraps the SwiftUI implementation using `UIHostingController`
- Supports both completion handler and delegate callback patterns
- Includes navigation bar integration (Cancel/Save buttons)
- Provides convenience methods for modal and push presentation

### AppKit Wrapper (macOS)
- `GradientEditorViewController` provides an AppKit-native interface
- Wraps the SwiftUI implementation using `NSHostingController`
- Supports both completion handler and delegate callback patterns
- Includes custom button layout for macOS conventions
- Provides convenience methods for sheet and modal window presentation

### Progressive Disclosure
All three interfaces follow the principle of progressive disclosure:
- Simple initialization for basic use cases
- Optional delegate/completion patterns for different developer preferences
- Convenience presentation methods that handle common scenarios

## User Interface

### General Rules

- The UI should be designed to work in both vertical and horizontal aspect ratios on both iPhone and iPad scale screens.
- The UI should adhere to Apple's accessibility guidelines, providing annotations on all functional and informational UI elements.
- All user-facing strings, whether displayed or part of accessibility, must be localizable. Only developer-facing strings such as internal identifiers are allowed to be static strings.

### Gradient Preview

- This is the primary UI that shows the user a preview of their gradient, based on current configuration.
- It should be a narrow strip containing a linear gradient that displays a preview of the current configuration.
- It should layout with the strip using the longer axis of the view automatically. So a portrait view would have a vertical strip with the stops on its right edge, where a landscape view would have a horizontal strip on the bottom with the stops above it.
- Along one edge of the gradient strip, there will be views representing the points along the gradient where color stops are.
- The color stop views are draggable (only along the axis of the gradient strip) and will update the appearance of the gradient in real time.
- A pinch/zoom gesture can be used to scale the gradient bar up and down. This does not change the bar's size on screen, but changes the scaling of the gradient and stop views so that closely-spaced stops can be moved precisely.
- When the gradient is zoomed beyond 100%, dragging up and down on the strip will "scroll" the visible portion of the gradient and the corresponding stops. I do not want to use a UIScrollView for this because it will make interacting with the stops (to drag them) very difficult.
- The gradient should have a maximum "zoom" of 400% and a minimum zoom of 100%.
- It is okay for stops to go off-screen based on the current zoom/pan state.
- The current stop view design is a little too chunky. I'd like to make them somewhat smaller, but still being easy to touch and interact with per the Human Interface Guidelines.

### Stop Editor

- This is a supplemental UI that appears when a stop is selected by tapping on it.
- The UI allows the user to configure the following properties of the selected stop:
  - Type: Single or Dual
  - The color(s) of the stop. We can start by using the system-provided color picker.
  - The precise position of the stop: 0-1 scale. This should be numeric text entry.
- There should also be controls to delete the stop and duplicate it. Any stop created through duplication will appear half-way between the original stop and the next-highest positional stop. If it is the final stop being duplicated, it will instead appear half-way to the previous stop.
- Due to screen space constraints, the presentation of this UI should be based on the size class of the view. If it is narrow (phone or split-screen iPad), then it should present over the gradient preview and be dismissable. If there is enough space, it should present next to the gradient preview.

## Example App

- I would like the package to have an example app embedded in the package that allows me to test the UI on device and allows integrators to try out the package.
  - First screen should be a list of pre-made ColorSchemes that, when tapped, launch the GradientEditor UI with the scheme.

## Testing

- I want Unit and UI tests covering the majority of the code in this package.
- You MUST USE Swift Tests AND NOT USE XCTest.
