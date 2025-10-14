import SwiftData
import SwiftUI

#if !os(macOS)

  public struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query(filter: #Predicate<Folder> { $0.name == "Root" }) var folders: [Folder]
    @State var router = NavigationRouter()
    @State var isPresentedSettingsView: Bool = false
    @State var editMode: EditMode = .inactive
    @State var selectedItemIds: Set<UUID> = []
    
    public init() {}

    public var body: some View {
      NavigationStack(path: $router.routes) {
        if let rootFolder = folders.first {
          List(selection: $selectedItemIds) {
            FoldersView(parentFolder: rootFolder)
          }
          .environment(\.editMode, $editMode)
          .navigationTitle("HTTP Requests")
          .navigationDestination(for: NavigationRouter.Route.self) { route in
            switch route {
            case .request(let request):
              RequestDetailView(request: request)
            case .requestResult(let result):
              ResultDetailView(result: result)
            }
          }
          .sheet(isPresented: $isPresentedSettingsView) {
            SettingsView()
          }
          .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
              if editMode == .active {
                Button("Done") {
                  editMode = .inactive
                }
              } else {
                Menu {
                  if editMode != .active {
                    Section {
                      Button {
                        editMode = .active
                      } label: {
                        Label("Select", systemImage: "checkmark.circle")
                      }
                    }
                  }

                  Section {
                    Button {
                      let newFolder = rootFolder.createNewFolder()
                      modelContext.insert(newFolder)
                      rootFolder.childrenFolders.append(newFolder)
                    } label: {
                      Label("Add Folder", systemImage: "folder.badge.plus")
                    }
                    Button {
                      let request = rootFolder.createNewRequest()
                      modelContext.insert(request)
                      rootFolder.childrenRequests.append(request)
                    } label: {
                      Label("Add Request", systemImage: "doc.badge.plus")
                    }
                  }
                  Section {
                    Button {
                      isPresentedSettingsView.toggle()
                    } label: {
                      Label("Settings", systemImage: "gear")
                    }
                  }
                } label: {
                  Label("Menu", systemImage: "ellipsis.circle")
                }
              }
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
