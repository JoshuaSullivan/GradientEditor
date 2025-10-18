import Foundation

/// Accessibility identifiers for UI testing and debugging.
public enum AccessibilityIdentifiers {
    // MARK: - Gradient Edit View
    public static let gradientPreview = "gradient_preview"
    public static let gradientStrip = "gradient_strip"
    public static let settingsButton = "settings_button"
    public static let addStopButton = "add_stop_button"
    public static let saveButton = "save_button"
    public static let cancelButton = "cancel_button"
    public static let exportButton = "export_button"

    // MARK: - Color Stop
    public static func colorStopHandle(id: String) -> String {
        "color_stop_handle_\(id)"
    }

    // MARK: - Color Stop Editor
    public static let stopEditor = "stop_editor"
    public static let stopEditorClose = "stop_editor_close"
    public static let stopEditorPrev = "stop_editor_prev"
    public static let stopEditorNext = "stop_editor_next"
    public static let stopEditorDelete = "stop_editor_delete"
    public static let stopEditorDuplicate = "stop_editor_duplicate"
    public static let stopEditorPosition = "stop_editor_position"
    public static let stopEditorTypePicker = "stop_editor_type_picker"
    public static let stopEditorColorPicker = "stop_editor_color_picker"
    public static let stopEditorFirstColorPicker = "stop_editor_first_color_picker"
    public static let stopEditorSecondColorPicker = "stop_editor_second_color_picker"

    // MARK: - Scheme Metadata Editor
    public static let schemeMetadataName = "scheme_metadata_name"
    public static let schemeMetadataDescription = "scheme_metadata_description"
    public static let schemeMetadataSave = "scheme_metadata_save"
    public static let schemeMetadataCancel = "scheme_metadata_cancel"
}
