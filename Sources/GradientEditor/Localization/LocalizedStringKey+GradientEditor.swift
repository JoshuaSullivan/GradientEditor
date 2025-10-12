import SwiftUI

/// Type-safe localized string keys for the GradientEditor package.
extension LocalizedStringKey {
    // MARK: - Color Stop Types
    nonisolated(unsafe) static let colorStopTypeSingle = LocalizedStringKey("color_stop_type_single")
    nonisolated(unsafe) static let colorStopTypeDual = LocalizedStringKey("color_stop_type_dual")

    // MARK: - Editor Labels
    nonisolated(unsafe) static let editorPositionLabel = LocalizedStringKey("editor_position_label")
    nonisolated(unsafe) static let editorColorLabel = LocalizedStringKey("editor_color_label")
    nonisolated(unsafe) static let editorFirstColorLabel = LocalizedStringKey("editor_first_color_label")
    nonisolated(unsafe) static let editorSecondColorLabel = LocalizedStringKey("editor_second_color_label")
    nonisolated(unsafe) static let editorDeleteButton = LocalizedStringKey("editor_delete_button")
    nonisolated(unsafe) static let editorDuplicateButton = LocalizedStringKey("editor_duplicate_button")
    nonisolated(unsafe) static let editorPickerTitle = LocalizedStringKey("editor_picker_title")
}

/// Type-safe localized strings for use in non-SwiftUI contexts.
public enum LocalizedString {
    // MARK: - Color Stop Types
    public static let colorStopTypeSingle = String(localized: "color_stop_type_single", bundle: .module)
    public static let colorStopTypeDual = String(localized: "color_stop_type_dual", bundle: .module)

    // MARK: - Editor Labels
    public static let editorPositionLabel = String(localized: "editor_position_label", bundle: .module)
    public static let editorColorLabel = String(localized: "editor_color_label", bundle: .module)
    public static let editorFirstColorLabel = String(localized: "editor_first_color_label", bundle: .module)
    public static let editorSecondColorLabel = String(localized: "editor_second_color_label", bundle: .module)
    public static let editorDeleteButton = String(localized: "editor_delete_button", bundle: .module)
    public static let editorDuplicateButton = String(localized: "editor_duplicate_button", bundle: .module)
    public static let editorPickerTitle = String(localized: "editor_picker_title", bundle: .module)

    // MARK: - Errors
    public static let errorInsufficientStops = String(localized: "error_insufficient_stops", bundle: .module)
    public static func errorInvalidPosition(_ position: CGFloat) -> String {
        String(localized: "error_invalid_position", bundle: .module)
    }
    public static let errorEncodingFailed = String(localized: "error_encoding_failed", bundle: .module)
    public static let errorDecodingFailed = String(localized: "error_decoding_failed", bundle: .module)

    // MARK: - Error Recovery
    public static let errorRecoveryAddStops = String(localized: "error_recovery_add_stops", bundle: .module)
    public static let errorRecoveryAdjustPosition = String(localized: "error_recovery_adjust_position", bundle: .module)
    public static let errorRecoveryTryAgain = String(localized: "error_recovery_try_again", bundle: .module)
}
