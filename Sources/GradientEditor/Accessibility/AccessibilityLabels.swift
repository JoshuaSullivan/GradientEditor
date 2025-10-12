import Foundation

/// Accessibility label constants for VoiceOver support.
/// These provide localized, user-friendly descriptions of UI elements.
public enum AccessibilityLabels {
    // MARK: - Gradient Edit View
    public static let gradientPreview = String(localized: "a11y_gradient_preview", bundle: .module, comment: "Accessibility label for the gradient preview area")
    public static let addStopButton = String(localized: "a11y_add_stop_button", bundle: .module, comment: "Accessibility label for add color stop button")
    public static let saveButton = String(localized: "a11y_save_button", bundle: .module, comment: "Accessibility label for save gradient button")
    public static let cancelButton = String(localized: "a11y_cancel_button", bundle: .module, comment: "Accessibility label for cancel editing button")
    public static let exportButton = String(localized: "a11y_export_button", bundle: .module, comment: "Accessibility label for export gradient button")

    // MARK: - Color Stop
    public static func colorStopHandle(position: CGFloat, type: String) -> String {
        String(localized: "a11y_color_stop_handle \(type) \(String(format: "%.1f", position * 100))", bundle: .module, comment: "Accessibility label for color stop handle")
    }

    // MARK: - Color Stop Editor
    public static let stopEditorClose = String(localized: "a11y_stop_editor_close", bundle: .module, comment: "Close color stop editor")
    public static let stopEditorPrev = String(localized: "a11y_stop_editor_prev", bundle: .module, comment: "Previous color stop")
    public static let stopEditorNext = String(localized: "a11y_stop_editor_next", bundle: .module, comment: "Next color stop")
    public static let stopEditorDelete = String(localized: "a11y_stop_editor_delete", bundle: .module, comment: "Delete color stop")
    public static let stopEditorDuplicate = String(localized: "a11y_stop_editor_duplicate", bundle: .module, comment: "Duplicate color stop")
}

/// Accessibility hint constants providing additional context for VoiceOver users.
public enum AccessibilityHints {
    // MARK: - Gradient Edit View
    public static let addStopButton = String(localized: "a11y_hint_add_stop", bundle: .module, comment: "Hint: Double tap to add a new color stop to the gradient")
    public static let saveButton = String(localized: "a11y_hint_save", bundle: .module, comment: "Hint: Double tap to save the gradient and close the editor")
    public static let cancelButton = String(localized: "a11y_hint_cancel", bundle: .module, comment: "Hint: Double tap to cancel editing and discard changes")

    // MARK: - Color Stop
    public static let colorStopHandle = String(localized: "a11y_hint_color_stop", bundle: .module, comment: "Hint: Double tap to edit this color stop, or drag to adjust its position")

    // MARK: - Color Stop Editor
    public static let stopEditorPrev = String(localized: "a11y_hint_prev_stop", bundle: .module, comment: "Hint: Double tap to edit the previous color stop")
    public static let stopEditorNext = String(localized: "a11y_hint_next_stop", bundle: .module, comment: "Hint: Double tap to edit the next color stop")
    public static let stopEditorDelete = String(localized: "a11y_hint_delete_stop", bundle: .module, comment: "Hint: Double tap to delete this color stop")
    public static let stopEditorDuplicate = String(localized: "a11y_hint_duplicate_stop", bundle: .module, comment: "Hint: Double tap to create a copy of this color stop")
}
