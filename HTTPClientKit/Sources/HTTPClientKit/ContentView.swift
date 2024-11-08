import SwiftUI
import SwiftData

public struct ContentView: View {
  @State var resultState: ResultState = .init()
  @State var selectedItemId: Item.ID?
  @Environment(\.modelContext) var modelContext
  @Query var folders: [Folder]
  @Query var files: [File]
  
  public init() {}

  public var body: some View {
    NavigationSplitView {
      List(selection: $selectedItemId) {
        FoldersView()
      }
      .contextMenu {
        Button("Add Folder") {
          let newFolder = Folder(name: "NewFolder1")
          modelContext.insert(newFolder)
        }
        Button("Add File") {
          let newFile = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"))
          modelContext.insert(newFile)
        }
      }
    } content: {
      if let selectedItemId = selectedItemId,
         let selectedItem = (folders.map(Item.folder) + files.map(Item.file)).first(where: { $0.id == selectedItemId }) {
        switch selectedItem {
        case .folder(let folder):
          Text(folder.name)
        case .file(let file):
          RequestDetailView(request: .init(get: { file.request}, set: { file.request = $0 }))
        }
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
