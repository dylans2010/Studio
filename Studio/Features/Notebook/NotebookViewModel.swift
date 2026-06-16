import SwiftUI
import Combine

class NotebookViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var selectedNoteId: UUID?

    var selectedNote: Note? {
        notes.first(where: { $0.id == selectedNoteId })
    }

    func createNote() {
        let newNote = Note(title: "New Note", blocks: [NoteBlock(type: .text, content: "")])
        notes.append(newNote)
        selectedNoteId = newNote.id
    }

    func addBlock(type: NoteBlock.BlockType) {
        guard let index = notes.firstIndex(where: { $0.id == selectedNoteId }) else { return }
        notes[index].blocks.append(NoteBlock(type: type, content: ""))
    }

    func updateBlock(id: UUID, content: String) {
        guard let noteIndex = notes.firstIndex(where: { $0.id == selectedNoteId }),
              let blockIndex = notes[noteIndex].blocks.firstIndex(where: { $0.id == id }) else { return }
        notes[noteIndex].blocks[blockIndex].content = content
    }
}
