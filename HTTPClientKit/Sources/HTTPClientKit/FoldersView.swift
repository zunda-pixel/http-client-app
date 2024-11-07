import SwiftUI

extension EnvironmentValues {
  @Entry var allItems: [Item] = []
}

struct FoldersView: View {
  @Environment(\.allItems) var allItems
  var parentId: UUID? = nil
  
  var body: some View {
    ForEach(self.allItems.filter { $0.parentId == parentId }) { item in
      switch item {
      case .folder(let folder):
        DisclosureGroup {
          FoldersView(parentId: folder.id)
        } label: {
          Label(folder.name, systemImage: "folder")
        }
          .id(folder.id)
      case .file(let file):
        Label(file.request.name, systemImage: "document")
          .id(file.id)
      }
    }
  }
}
