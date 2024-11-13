import HTTPTypes
import SwiftUI
import SwiftData

struct ItemView: View {
  @Environment(\.modelContext) var modelContext
  var parentFolder: Folder
  @State var editingFolderName: String?
  @State var selectedFolder: Folder?
  @State var isPresentedRenameAlert: Bool = false
  
  @Query var folders: [Folder]
  @Query var files: [File]
  
  init(
    parentFolder: Folder,
    childId: UUID
  ) {
    self.parentFolder = parentFolder
    _folders = .init(filter: #Predicate<Folder> { $0.id == childId })
    _files = .init(filter: #Predicate<File> { $0.id == childId })
  }

  var body: some View {
    if let folder = folders.first {
      DisclosureGroup {
        FoldersView(parentFolder: folder)
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
                let newFolder = Folder(name: "NewFolder1")
                modelContext.insert(newFolder)
                folder.childrenIds.append(newFolder.id)
              }
              
              Button("Delete Folder", role: .destructive) {
                folder.childrenIds.removeAll(where: { $0 == folder.id })
                modelContext.delete(folder)
              }
            }
            Section {
              Button("Add File") {
                let newFile = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"))
                modelContext.insert(newFile)
                folder.childrenIds.append(newFile.id)
              }
            }
          }
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
    } else if let file = files.first {
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
          parentFolder.childrenIds.removeAll(where: { $0 == file.id })
          modelContext.delete(file)
        }
        
        Button("Duplicate Request") {
          var newRequest = file.request
          newRequest.id = .init()
          let newFile = File(request: newRequest)
          modelContext.insert(newFile)
          parentFolder.childrenIds.append(newFile.id)
        }
        
        Button("New Request") {
          let newFile = File(request: Request(name: "NewRequest1", baseUrl: "https://apple.com"))
          modelContext.insert(newFile)
          parentFolder.childrenIds.append(newFile.id)
        }
      }
      .id(file.id)
    }
  }
}

struct FoldersView: View {
  var parentFolder: Folder

  var body: some View {
    ForEach(parentFolder.childrenIds, id: \.self) { childId in
      ItemView(parentFolder: parentFolder, childId: childId)
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
  @Previewable @State var selectedItemId: UUID?
  @Previewable @Query(filter: #Predicate<Folder> { $0.name == "Root" }) var folders: [Folder]
  if let rootFolder = folders.first {
    List(selection: $selectedItemId) {
      FoldersView(parentFolder: rootFolder)
    }
  }
}
