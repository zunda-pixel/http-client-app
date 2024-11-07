import SwiftUI

extension EnvironmentValues {
  @Entry var allItems: [Item] = []
}

struct FoldersView: View {
  @Environment(ItemController.self) var itemController
  @Environment(\.allItems) var allItems
  var parentId: Folder.ID? = nil
  
  var body: some View {
    ForEach(self.allItems.filter { $0.parentId == self.parentId }) { item in
      switch item {
      case .folder(let folder):
        DisclosureGroup {
          FoldersView(parentId: folder.id)
        } label: {
          Label(folder.name, systemImage: "folder")
            .contextMenu {
              Button("Add Folder") {
                itemController.items.append(.folder(.init(name: "NewFolder1", parentId: folder.id)))
              }
              Button("Add File") {
                itemController.items.append(.file(.init(request: .init(name: "NewRequest1"), folderId: folder.id)))
              }
            }
            .id(folder.id)
        }
      case .file(let file):
        Label("[\(file.request.method.rawValue)] \(file.request.name)", systemImage: "document")
          .contextMenu {
            Button("Delete", role: .destructive) {
              itemController.items.removeAll { $0.id.rawValue == file.id.rawValue }
            }
          }
          .id(file.id)
      }
    }
  }
}
