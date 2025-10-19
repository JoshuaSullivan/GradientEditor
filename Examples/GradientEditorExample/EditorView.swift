import SwiftUI
import GradientEditor

struct EditorView: View {
    let scheme: GradientColorScheme
    let onComplete: @Sendable (GradientEditorResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GradientEditViewModel

    init(scheme: GradientColorScheme, onComplete: @escaping @Sendable (GradientEditorResult) -> Void) {
        self.scheme = scheme
        self.onComplete = onComplete

        // Create view model with completion handler pre-configured
        self._viewModel = State(initialValue: GradientEditViewModel(scheme: scheme, onComplete: onComplete))
    }

    var body: some View {
        NavigationStack {
            GradientEditView(viewModel: viewModel)
                .navigationTitle(viewModel.scheme.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.cancelEditing()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let dismiss = self.dismiss
                            let onComplete = self.onComplete

                            viewModel.onComplete = { result in
                                Task { @MainActor in
                                    onComplete(result)
                                    dismiss()
                                }
                            }
                            viewModel.saveGradient()
                        }
                    }
                }
                .onAppear {
                    // Set up dismiss handler
                    let dismiss = self.dismiss
                    let onComplete = self.onComplete

                    viewModel.onComplete = { result in
                        Task { @MainActor in
                            onComplete(result)
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    EditorView(scheme: .wakeIsland) { result in
        print("Editor completed with result: \(result)")
    }
}
