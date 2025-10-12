# GradientEditor Example App

This folder contains an example iOS app demonstrating the GradientEditor package.

## Setup Instructions

The Xcode project has been created with a local package dependency on GradientEditor.

### Project Structure

```
Examples/
├── README.md (this file)
├── GradientEditorExample.xcodeproj/  (Xcode project)
└── GradientEditorExample/  (Source files)
    ├── GradientEditorExampleApp.swift - App entry point
    ├── SchemeListView.swift - Main list view
    ├── EditorView.swift - Gradient editor wrapper
    └── Assets.xcassets/
```

### Building and Running

1. Open `GradientEditorExample.xcodeproj` in Xcode
2. Select a simulator or device
3. Build and run (⌘R)

The project already has:
- Local package dependency configured (relative path to parent GradientEditor package)
- iOS 18.0 deployment target set
- All source files added to the target

### Optional: Remove Template File

If you see a `ContentView.swift` file in the project, you can delete it - it's just the Xcode template and isn't used.

## What the Example App Demonstrates

- **Scheme List View**: Displays all preset gradients with thumbnails
- **Gradient Editor**: Full editing experience with:
  - Zoom and pan gestures
  - Stop editing (add, delete, duplicate, position adjustment)
  - Color picker integration
  - Adaptive layout (compact vs regular width)
- **Save/Cancel Workflow**: Proper handling of the completion callback
- **Custom Gradients**: Ability to create new gradients and save modifications


## Testing Checklist

Once the app is running, test:

- [ ] All preset gradients display correctly
- [ ] Tapping a gradient opens the editor
- [ ] Zoom gesture (pinch) works
- [ ] Pan gesture works when zoomed
- [ ] Adding new stops works
- [ ] Deleting stops works
- [ ] Duplicating stops works
- [ ] Editing stop colors works
- [ ] Editing stop positions works
- [ ] Adaptive layout on iPhone (portrait = sheet, landscape = side-by-side)
- [ ] Adaptive layout on iPad (regular width = side-by-side)
- [ ] Save button creates a new custom gradient
- [ ] Cancel button dismisses without saving

## Notes

- This example app is separate from the package and will NOT be compiled when developers add GradientEditor as a dependency
- The app uses a local package reference, so changes to the package source are immediately reflected
- For testing on device, you may need to adjust the bundle identifier and signing settings
