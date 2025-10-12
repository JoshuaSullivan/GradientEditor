# Phase 4: Example App

**Status:** In Progress
**Started:** 2025-10-12

**Goal:** Create a functional example app for manual testing and demonstration

## 4.1 App Target Setup

- [ ] Design example app structure following SPM best practices
  - Ensure example app is NOT compiled when library is used as dependency
  - Research SPM example app patterns (Examples/ folder, separate Xcode project)
- [ ] Create example app target/project structure
- [ ] Set up app structure (App, Scenes, Views)
- [ ] Configure app metadata (Info.plist, icons, etc.)
- [ ] Ensure app builds and runs on device

## 4.2 Scheme List View

- [ ] Create main list view showing all presets
- [ ] Display ColorScheme name and description
- [ ] Show gradient preview thumbnail for each scheme
- [ ] Make list items tappable
- [ ] Add proper navigation structure

## 4.3 Editor Integration

- [ ] Launch GradientEditView when scheme is tapped
- [ ] Handle completion callback (save edited gradient)
- [ ] Handle error/cancel scenarios
- [ ] Test full workflow on device

## 4.4 Example App Features

- [ ] Add ability to save custom gradients
- [ ] Add ability to share gradients (export JSON)
- [ ] Add ability to import gradients from JSON
- [ ] Add basic settings or about screen

## 4.5 Testing & Validation

- [ ] Test on iPhone (various sizes)
- [ ] Test on iPad (all orientations and split views)
- [ ] Test all implemented features:
  - Zoom/pan gestures
  - Stop editing (add, delete, duplicate, modify)
  - Position validation
  - Adaptive layout (compact vs regular width)
  - Color picker integration
- [ ] Verify no compilation when used as dependency

## Notes

- **SPM Best Practice:** Example app should NOT be compiled by library consumers
- Consider using Examples/ folder with separate Xcode project
- Or use conditional compilation flags
- Document how to run the example app in README
- Use example app to validate all Phase 1-3 features work correctly in real integration
