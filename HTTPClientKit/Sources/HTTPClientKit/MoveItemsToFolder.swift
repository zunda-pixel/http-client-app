import SwiftData
import SwiftUI

#if !os(macOS)

struct MoveItemsToFolder: View {
  @Query var folders: [Folder]
  @State var selectedFolderId: Folder.ID?
  var rootFolder: Folder
  var ids: Set<UUID>
  @Environment(\.dismiss) var dismiss
  @Environment(\.modelContext) var modelContext

  func moveItems(folder: Folder) {
    var copiedIds = ids

    // if Move Folder, remove childrenIds from target ids
    for folder in folders where ids.contains(folder.id) {
      folder.childrenIds.forEach { copiedIds.remove($0) }
    }

    // if Move File, remove id from original folder childrenIds
    for id in ids {
      if let folder = folders.first(where: { $0.childrenIds.contains(id) }) {
        folder.childrenIds.removeAll { $0 == id }
      }
    }

    folder.childrenIds.append(contentsOf: copiedIds)

    dismiss()
  }

  var body: some View {
    NavigationStack {
      List(selection: $selectedFolderId) {
        if let selectedFolderId, let folder = folders.first(where: { $0.id == selectedFolderId }) {
          Section {
            Text("Selected: \(folder.name)")
            Button {
              moveItems(folder: folder)
              dismiss()
            } label: {
              Label("Move", systemImage: "folder")
            }
          }
        }
        Section("Folder") {
          foldersView(childrenIds: [rootFolder.id])
        }
      }
      .navigationTitle("Select Folder")
    }
    .environment(\.editMode, .constant(.active))
  }

  @ViewBuilder
  func foldersView(childrenIds: [UUID]) -> some View {
    ForEach(childrenIds.filter { !ids.contains($0) }, id: \.self) { id in
      if let folder = folders.first(where: { $0.id == id }) {
        DisclosureGroup {
          foldersView(childrenIds: folder.childrenIds)
        } label: {
          Text(folder.name)
        }
      }
    }
  }
}
#endif
