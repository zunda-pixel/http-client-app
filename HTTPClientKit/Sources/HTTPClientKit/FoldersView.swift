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
              Button("Delete", role: .destructive) {
                itemController.items.removeAll { $0.id.rawValue == folder.id.rawValue }
              }
            }
            .id(folder.id)
        }
      case .file(let file):
        
        LabeledContent {
          Text(file.request.name)
            .bold()
        } label: {
          Text(file.request.method.rawValue)
            .bold()
            .padding(.vertical, 2)
            .frame(maxWidth: 70)
            .background(file.request.method.color.opacity(0.7))
            .cornerRadius(8)
        }
        .padding(4)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(file.request.method.color.opacity(0.7), lineWidth: 1)
        )
        .contextMenu {
          Button("Delete", role: .destructive) {
            itemController.items.removeAll { $0.id.rawValue == file.id.rawValue }
          }
          
          Button("Duplicate") {
            var newRequest = file.request
            newRequest.id = .init()
            itemController.items.append(.file(.init(request: newRequest, folderId: file.folderId)))
          }
        }
        .id(file.id)
      }
    }
  }
}

import HTTPTypes

extension HTTPRequest.Method {
  var color: Color {
    switch self {
    case .get: return .blue
    case .post: return .green
    case .put: return .orange
    case .delete: return .red
    case .patch: return .purple
    case .head: return .pink
    case .options: return .yellow
    case .trace: return .gray
    case .connect: return .black
    default:
      fatalError()
    }
  }
}
