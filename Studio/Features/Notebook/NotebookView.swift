import SwiftUI

struct NotebookView: View {
    @StateObject private var viewModel = NotebookViewModel()
    @EnvironmentObject var aiContext: AIContext

    var body: some View {
        NavigationView {
            List(viewModel.notes, selection: $viewModel.selectedNoteId) { note in
                NavigationLink(destination: NoteEditorView(note: note, viewModel: viewModel)) {
                    VStack(alignment: .leading) {
                        Text(note.title.isEmpty ? "Untitled" : note.title)
                            .font(.headline)
                        Text(note.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tag(note.id)
            }
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem {
                    Button(action: viewModel.createNote) {
                        Label("New Note", systemImage: "plus")
                    }
                }
            }

            Text("Select a note or create a new one")
                .foregroundColor(.secondary)
        }
    }
}

struct NoteEditorView: View {
    var note: Note
    @ObservedObject var viewModel: NotebookViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                TextField("Title", text: Binding(
                    get: { note.title },
                    set: { newValue in
                        if let index = viewModel.notes.firstIndex(where: { $0.id == note.id }) {
                            viewModel.notes[index].title = newValue
                        }
                    }
                ))
                .font(.largeTitle)
                .textFieldStyle(.plain)

                ForEach(note.blocks) { block in
                    BlockView(block: block, onUpdate: { content in
                        viewModel.updateBlock(id: block.id, content: content)
                    })
                }

                Menu {
                    ForEach(NoteBlock.BlockType.allCases, id: \.self) { type in
                        Button(type.rawValue.capitalized) {
                            viewModel.addBlock(type: type)
                        }
                    }
                } label: {
                    Label("Add Block", systemImage: "plus.circle")
                }
                .menuStyle(.borderlessButton)
            }
            .padding()
        }
    }
}

struct BlockView: View {
    let block: NoteBlock
    var onUpdate: (String) -> Void

    var body: some View {
        Group {
            if block.type == .header {
                TextField("Header", text: Binding(get: { block.content }, set: onUpdate))
                    .font(.title2)
                    .textFieldStyle(.plain)
            } else if block.type == .code {
                TextEditor(text: Binding(get: { block.content }, set: onUpdate))
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(4)
                    .frame(minHeight: 100)
            } else {
                TextEditor(text: Binding(get: { block.content }, set: onUpdate))
                    .frame(minHeight: 50)
            }
        }
    }
}
