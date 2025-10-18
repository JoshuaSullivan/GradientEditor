import SwiftUI

/// A view for editing gradient scheme metadata (name and description).
struct SchemeMetadataEditorView: View {

    @Binding var name: String
    @Binding var description: String

    let onSave: () -> Void
    let onCancel: () -> Void

    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($isNameFocused)
                        .accessibilityIdentifier(AccessibilityIdentifiers.schemeMetadataName)
                } header: {
                    Text("Gradient Name")
                }

                Section {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .accessibilityIdentifier(AccessibilityIdentifiers.schemeMetadataDescription)
                } header: {
                    Text("Description")
                }
            }
            .navigationTitle("Gradient Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.schemeMetadataCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier(AccessibilityIdentifiers.schemeMetadataSave)
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
}

#Preview {
    SchemeMetadataEditorView(
        name: .constant("Wake Island"),
        description: .constant("A tropical island color scheme sampled from photos of Wake Island."),
        onSave: {},
        onCancel: {}
    )
}
