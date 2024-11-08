import HTTPTypes
import SwiftUI
import SwiftData

struct FoldersView: View {
  @Environment(\.modelContext) var modelContext
  @Query var folders: [Folder]
  @Query var files: [File]
  var allItems: [Item] {
    folders.map(Item.folder) + files.map(Item.file)
  }
  var parentId: Folder.ID? = nil

  @State var selectedFolder: Folder?
  @State var editingFolderName: String?
  @State var isPresentedRenameAlert = false
  
  var body: some View {
    ForEach(self.allItems.filter { $0.parentId == self.parentId }) { item in
      switch item {
      case .folder(let folder):
        DisclosureGroup {
          FoldersView(parentId: folder.id)
        } label: {
          Label(folder.name, systemImage: "folder")
            .contextMenu {
              Section {
                Button("Rename Folder") {
                  selectedFolder = folder
                  editingFolderName = folder.name
                  isPresentedRenameAlert.toggle()
                }
              }
              Section {
                Button("Add Folder") {
                  let newFolder = Folder(name: "NewFolder1", parentId: folder.id)
                  modelContext.insert(newFolder)
                }
                
                Button("Delete Folder", role: .destructive) {
                  modelContext.delete(folder)
                }
              }
              Section {
                Button("Add File") {
                  let newFile = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"), folderId: folder.id)
                  modelContext.insert(newFile)
                }
              }
            }
            .id(folder.id)
        }
        .alert(
          "Rename Folder",
          isPresented: $isPresentedRenameAlert,
          presenting: editingFolderName
        ) { folderName in
          TextField("Folder Name", text: .init(get: { self.editingFolderName ?? folderName }, set: { self.editingFolderName = $0 }))
          Button("OK") { selectedFolder?.name = editingFolderName ?? folderName }
          Button("Cancel", role: .cancel) {
            selectedFolder = nil
            editingFolderName = nil
          }
        } message: { _ in
          Text("Please enter a folder name.")
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
          Button("Delete Request", role: .destructive) {
            modelContext.delete(file)
          }

          Button("Duplicate Request") {
            var newRequest = file.request
            newRequest.id = .init()
            let newFile = File(request: newRequest, folderId: file.folderId)
            modelContext.insert(newFile)
          }

          Button("New Request") {
            let newFile = File(request: Request(name: "NewRequest1", baseUrl: "https://apple.com"), folderId: file.folderId)
            modelContext.insert(newFile)
          }
        }
        .id(file.id)
      }
    }
  }
}

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

#Preview {
  @Previewable @State var selectedItemId: Item.ID?
  return List(selection: $selectedItemId) {
    FoldersView()
  }
}
