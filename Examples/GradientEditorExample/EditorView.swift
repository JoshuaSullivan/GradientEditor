import SwiftUI
import GradientEditor

struct EditorView: View {
    let scheme: ColorScheme
    let onComplete: (GradientEditorResult) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: GradientEditViewModel

    init(scheme: ColorScheme, onComplete: @escaping (GradientEditorResult) -> Void) {
        self.scheme = scheme
        self.onComplete = onComplete
        self._viewModel = State(initialValue: GradientEditViewModel(scheme: scheme))
    }

    var body: some View {
        NavigationStack {
            GradientEditView(viewModel: viewModel)
                .navigationTitle(scheme.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            viewModel.cancelEditing()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.saveGradient()
                        }
                    }
                }
                .onAppear {
                    // Set up the completion handler
                    viewModel.onComplete = { result in
                        onComplete(result)
                        dismiss()
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
