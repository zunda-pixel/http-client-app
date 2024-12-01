import SwiftData
import SwiftUI

#if os(macOS)
  public struct ContentView: View {
    @State var resultState: ResultState = .init()
    @State var selectedRequest: Request?
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Folder> { $0.name == "Root" }) var folders: [Folder]

    public init() {}

    public var body: some View {
      NavigationSplitView {
        if let rootFolder = folders.first {
          List(selection: $selectedRequest) {
            FoldersView(parentFolder: rootFolder)
          }
          .contextMenu {
            Button {
              let newFolder = Folder(name: "NewFolder1")
              modelContext.insert(newFolder)
              rootFolder.childrenFolders.append(newFolder)
            } label: {
              Label("Add Folder", systemImage: "folder.badge.plus")
            }
            Button {
              let newRequest = Request(name: "NewRequest1", baseUrl: "https://apple.com")
              modelContext.insert(newRequest)
              rootFolder.childrenRequests.append(newRequest)
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
        if let selectedRequest {
          RequestDetailView(request: selectedRequest)
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
#endif
