import SwiftUI
import SwiftData

#if !os(macOS)

public struct ContentView: View {
  @Environment(\.modelContext) var modelContext
  @Query(filter: #Predicate<Folder> { $0.name == "Root"}) var folders: [Folder]
  @State var router = NavigationRouter()
  
  public init() {
    
  }
  public var body: some View {
    NavigationStack(path: $router.routes) {
      if let rootFolder = folders.first {
        List {
          FoldersView(parentFolder: rootFolder)
        }
        .navigationDestination(for: NavigationRouter.Route.self) { route in
          switch route {
          case .request(let file):
            RequestDetailView(request: .init(get: { file.request }, set: { file.request = $0 }))
          case .requestResult(let result):
            ResultDetailView(result: result)
          }
        }
        .toolbar {
          ToolbarItemGroup {
            Menu {
              Button("Add Folder") {
                let folder = Folder(name: "NewFolder1")
                modelContext.insert(folder)
                rootFolder.childrenIds.append(folder.id)
              }
              Button("Add File") {
                let file = File(request: .init(name: "NewRequest1", baseUrl: "https://apple.com"))
                modelContext.insert(file)
                rootFolder.childrenIds.append(file.id)
              }
            } label: {
              Label("Add", systemImage: "plus")
            }
            EditButton()
          }
        }
      } else {
        VStack {
          Text("No root folder found")
            .font(.title)
          Button("Add Root Folder") {
            let folder = Folder(name: "Root")
            modelContext.insert(folder)
          }
        }
      }
    }
    .environment(router)
  }
}

#endif
