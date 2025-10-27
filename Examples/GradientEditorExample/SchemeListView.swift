import SwiftUI
import GradientEditor

struct SchemeListView: View {
    @State private var schemes: [GradientColorScheme] = GradientColorScheme.allPresets
    @State private var selectedScheme: GradientColorScheme?
    @State private var customSchemes: [GradientColorScheme] = []

    var allSchemes: [GradientColorScheme] {
        schemes + customSchemes
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Preset Gradients") {
                    ForEach(schemes) { scheme in
                        SchemeRow(scheme: scheme)
                            .onTapGesture {
                                selectedScheme = scheme
                            }
                    }
                }

                if !customSchemes.isEmpty {
                    Section("Custom Gradients") {
                        ForEach(customSchemes) { scheme in
                            SchemeRow(scheme: scheme)
                                .onTapGesture {
                                    selectedScheme = scheme
                                }
                        }
                        .onDelete { indexSet in
                            customSchemes.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Gradient Editor")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        createNewGradient()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedScheme) { scheme in
                EditorView(scheme: scheme) { result in
                    handleEditorResult(result, for: scheme)
                }
            }
        }
    }

    private func createNewGradient() {
        let newScheme = GradientColorScheme(
            name: "New Gradient",
            description: "A custom gradient",
            colorMap: ColorMap(stops: [
                ColorStop(position: 0.0, type: .single(.blue)),
                ColorStop(position: 1.0, type: .single(.purple))
            ])
        )
        selectedScheme = newScheme
    }

    private func handleEditorResult(_ result: GradientEditorResult, for originalScheme: GradientColorScheme) {
        selectedScheme = nil

        switch result {
        case .saved(let updatedScheme):
            // If it's a custom scheme, update it
            if let index = customSchemes.firstIndex(where: { $0.id == updatedScheme.id }) {
                customSchemes[index] = updatedScheme
            } else {
                // It's a preset being edited, add it as a custom scheme
                customSchemes.append(updatedScheme)
            }

        case .cancelled:
            // Do nothing
            break
        }
    }
}

struct SchemeRow: View {
    let scheme: GradientColorScheme

    var body: some View {
        HStack(spacing: 12) {
            // Gradient preview thumbnail
            GradientThumbnail(colorMap: scheme.colorMap)
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(scheme.name)
                    .font(.headline)

                Text(scheme.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct GradientThumbnail: View {
    let colorMap: ColorMap

    var body: some View {
        Rectangle()
            .fill(colorMap.linearGradient())
    }
}

#Preview {
    SchemeListView()
}
