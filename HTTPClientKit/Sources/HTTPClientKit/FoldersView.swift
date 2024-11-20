import HTTPTypes
import SwiftUI
import SwiftData

struct FoldersView: View {
  var parentFolder: Folder

  var body: some View {
    ForEach(parentFolder.childrenIds, id: \.self) { childId in
      ItemView(parentFolder: parentFolder, itemId: childId)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
    .onMove { source, destination in
      parentFolder.childrenIds.move(fromOffsets: source, toOffset: destination)
    }
  }
}

#if os(macOS)
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
    itemId: UUID
  ) {
    self.parentFolder = parentFolder
    _folders = .init(filter: #Predicate<Folder> { $0.id == itemId })
    _files = .init(filter: #Predicate<File> { $0.id == itemId })
  }

  var body: some View {
    if let folder = folders.first {
      DisclosureGroup {
        FoldersView(parentFolder: folder)
      } label: {
        Label(folder.name, systemImage: "folder")
          .contextMenu {
            Section {
              Button {
                selectedFolder = folder
                editingFolderName = folder.name
                isPresentedRenameAlert.toggle()
              } label: {
                Label("Rename", systemImage: "pencil")
              }
            }
            Section {
              Button {
                let newFolder = Folder(name: "NewFolder1")
                modelContext.insert(newFolder)
                folder.childrenIds.append(newFolder.id)
              } label: {
                Label("Add Folder", systemImage: "folder.badge.plus")
              }
              Button {
                let newFile = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"))
                modelContext.insert(newFile)
                folder.childrenIds.append(newFile.id)
              } label: {
                Label("Add File", systemImage: "doc.badge.plus")
              }
            }
            Section {
              Button(role: .destructive) {
                folder.childrenIds.removeAll(where: { $0 == folder.id })
                modelContext.delete(folder)
              } label: {
                Label("Delete", systemImage: "trash")
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
        Section {
          Button {
            var newRequest = file.request
            newRequest.id = .init()
            let newFile = File(request: newRequest)
            modelContext.insert(newFile)
            parentFolder.childrenIds.append(newFile.id)
          } label: {
            Label("Duplicate Request", systemImage: "doc.on.doc")
          }
          
          Button {
            let newFile = File(request: Request(name: "NewRequest1", baseUrl: "https://apple.com"))
            modelContext.insert(newFile)
            parentFolder.childrenIds.append(newFile.id)
          } label: {
            Label("New Request", systemImage: "doc.badge.plus")
          }
        }
        
        Section {
          Button(role: .destructive) {
            parentFolder.childrenIds.removeAll(where: { $0 == file.id })
            modelContext.delete(file)
          } label: {
            Label("Delete Request", systemImage: "trash")
          }
        }
      }
      .id(file.id)
    } else {
      fatalError()
    }
  }
}
#else
struct ItemView: View {
  @Environment(\.modelContext) var modelContext
  @Environment(NavigationRouter.self) var router
  var parentFolder: Folder
  @Query var folders: [Folder]
  @Query var files: [File]
  @State var editingFolderName: String?
  @State var selectedFolder: Folder?
  @State var isPresentedRenameAlert: Bool = false

  init(
    parentFolder: Folder,
    itemId: UUID
  ) {
    self.parentFolder = parentFolder
    _folders = .init(filter: #Predicate<Folder> { $0.id == itemId })
    _files = .init(filter: #Predicate<File> { $0.id == itemId })
  }
  
  var body: some View {
    if let folder = folders.first {
      DisclosureGroup {
        FoldersView(parentFolder: folder)
      } label: {
        Label(folder.name, systemImage: "folder")
          .contextMenu {
            Section {
              Button {
                selectedFolder = folder
                editingFolderName = folder.name
                isPresentedRenameAlert.toggle()
              } label: {
                Label("Rename", systemImage: "pencil")
              }
            }
            Section {
              Button(role: .destructive) {
                folder.childrenIds.removeAll(where: { $0 == folder.id })
                modelContext.delete(folder)
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
            Section {
              Button {
                let newFolder = Folder(name: "NewFolder1")
                modelContext.insert(newFolder)
                folder.childrenIds.append(newFolder.id)
              } label: {
                Label("Add Folder", systemImage: "folder")
              }
              Button {
                let newFile = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"))
                modelContext.insert(newFile)
                folder.childrenIds.append(newFile.id)
              } label: {
                Label("Add File", systemImage: "document")
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
      HStack {
        Text(file.request.method.rawValue)
          .bold()
          .foregroundStyle(.white)
          .frame(minWidth: 80)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(file.request.method.color.opacity(0.8))
          .cornerRadius(8)
        
        Text(file.request.name)
      }
        .contentShape(.rect)
        .onTapGesture {
          router.routes.append(.request(file))
        }
        .swipeActions {
          Button(role: .destructive) {
            parentFolder.childrenIds.removeAll(where: { $0 == file.id })
            modelContext.delete(file)
          } label: {
            Label("Delete", systemImage: "trash")
          }
          
          Button {
            var newRequest = file.request
            newRequest.id = .init()
            let newFile = File(request: newRequest)
            modelContext.insert(newFile)
            parentFolder.childrenIds.append(newFile.id)
          } label: {
            Label("Duplicate", systemImage: "plus.square.on.square")
          }
        }
    } else {
      fatalError()
    }
  }
}
#endif

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
