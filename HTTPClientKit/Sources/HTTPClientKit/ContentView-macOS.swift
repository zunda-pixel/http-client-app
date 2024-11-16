import SwiftUI
import SwiftData

#if os(macOS)
public struct ContentView: View {
  @State var resultState: ResultState = .init()
  @State var selectedItemId: UUID?
  @Environment(\.modelContext) var modelContext
  @Query(filter: #Predicate<Folder> { $0.name == "Root"}) var folders: [Folder]
  @Query var files: [File]
  
  public init() {}

  public var body: some View {
    NavigationSplitView {
      if let rootFolder = folders.first {
        List(selection: $selectedItemId) {
          FoldersView(parentFolder: rootFolder)
        }
        .contextMenu {
          Button {
            let newFolder = Folder(name: "NewFolder1")
            modelContext.insert(newFolder)
            rootFolder.childrenIds.append(newFolder.id)
          } label: {
            Label("Add Folder", systemImage: "folder.badge.plus")
          }
          Button {
            let newFile = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"))
            modelContext.insert(newFile)
            rootFolder.childrenIds.append(newFile.id)
          } label: {
            Label("Add File", systemImage: "doc.badge.plus")
          }
        }
      } else {
        VStack {
          Text("No root folder found")
          Button("Add Root Folder") {
            let newRootFolder = Folder(name: "Root")
            modelContext.insert(newRootFolder)
          }
        }
        
      }
    } content: {
      if let selectedItemId = selectedItemId {
        ItemDetailView(itemId: selectedItemId)
      } else {
        ContentUnavailableView("No item selected", systemImage: "house")
      }
    } detail: {
      if let result = resultState.result {
        ResultDetailView(result: result)
      }
    }
    .environment(resultState)
  }
}

struct ItemDetailView: View {
  @Query var folders: [Folder]
    @Query var files: [File]
  
  init(itemId: UUID) {
    _folders = .init(filter: #Predicate<Folder> { $0.id == itemId })
    _files = .init(filter: #Predicate<File> { $0.id == itemId })
  }

  var body: some View {
    if let folder = folders.first {
      Text(folder.name)
    } else if let file = files.first {
      RequestDetailView(request: .init(get: { file.request }, set: { file.request = $0 }))
    } else {
      Text("No item found")
        .foregroundStyle(.red)
    }
  }
}
#endif

