import HTTPTypes
import SwiftData
import SwiftUI

struct FoldersView: View {
  var parentFolder: Folder

  var body: some View {
    ForEach(parentFolder.childrenFolders) { folder in
      FolderCell(folder: folder)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
    .onMove { source, destination in
      parentFolder.childrenFolders.move(
        fromOffsets: source,
        toOffset: destination
      )
    }
    ForEach(parentFolder.childrenRequests) { request in
      RequestCell(parentFolder: parentFolder, request: request)
        .id(request)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
    .onMove { source, destination in
      parentFolder.childrenRequests.move(
        fromOffsets: source,
        toOffset: destination
      )
    }
  }
}

struct FolderCell: View {
  @Environment(\.modelContext) var modelContext
  var folder: Folder
  @State var editingFolderName: String?
  @State var selectedFolder: Folder?
  @State var isPresentedRenameAlert: Bool = false
  var body: some View {
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
              folder.childrenFolders.append(newFolder)
            } label: {
              Label("Add Folder", systemImage: "folder.badge.plus")
            }
            Button {
              let newRequest = Request(name: "NewRequest1", baseUrl: "https://apple.com")
              modelContext.insert(newRequest)
              folder.childrenRequests.append(newRequest)
            } label: {
              Label("Add Request", systemImage: "doc.badge.plus")
            }
          }
        }
    }
    .alert(
      "Rename Folder",
      isPresented: $isPresentedRenameAlert,
      presenting: editingFolderName
    ) { folderName in
      TextField(
        "Folder Name",
        text: .init(
          get: { self.editingFolderName ?? folderName },
          set: { self.editingFolderName = $0 }
        )
      )
      Button("OK") {
        selectedFolder?.name = editingFolderName ?? folderName
      }
      Button("Cancel", role: .cancel) {
        selectedFolder = nil
        editingFolderName = nil
      }
    } message: { _ in
      Text("Please enter a folder name.")
    }
  }
}

#if os(macOS)
  struct RequestCell: View {
    @Environment(\.modelContext) var modelContext
    
    var parentFolder: Folder
    var request: Request
    
    var body: some View {
      LabeledContent {
        Text(request.name)
          .bold()
      } label: {
        Text(request.method.rawValue)
          .bold()
          .padding(.vertical, 2)
          .frame(maxWidth: 70)
          .background(request.method.color.opacity(0.7))
          .cornerRadius(8)
      }
      .padding(4)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(request.method.color.opacity(0.7), lineWidth: 1)
      )
      .contextMenu {
        Button(role: .destructive) {
          parentFolder.childrenRequests.removeAll { $0.id == request.id }
          modelContext.delete(request)
        } label: {
          Label("Delete", systemImage: "trash")
        }
      }
    }
  }
#else
  struct RequestCell: View {
    @Environment(\.modelContext) var modelContext
    @Environment(NavigationRouter.self) var router
    var parentFolder: Folder
    var request: Request
    
    var body: some View {
      HStack {
        Text(request.method.rawValue)
          .bold()
          .foregroundStyle(.white)
          .frame(minWidth: 80)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(request.method.color.opacity(0.8))
          .cornerRadius(8)

        Text(request.name)
      }
      .contentShape(.rect)
      .onTapGesture {
        router.routes.append(.request(request))
      }
      .swipeActions {
        Button(role: .destructive) {
          parentFolder.childrenRequests.removeAll { $0.id == request.id }
          modelContext.delete(request)
        } label: {
          Label("Delete", systemImage: "trash")
        }
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
