import SwiftUI

public struct ContentView: View {
  @State var resultState: ResultState = .init()
  @State var selectedItemId: Item.ID?
  @State var allItems: [Item] = [
    .folder(.github),
    .folder(.githubUsers),
    .folder(.githubRepositories),
    .folder(.google),
    .folder(.googleAuth),
    .folder(.weather),
    .folder(.aws),
    .file(.githubUsersGet),
    .file(.githubRepositoriesGet),
    .file(.googleAuthGet),
  ]
  
  public init() { }

  public var body: some View {
    NavigationSplitView {
      List(selection: $selectedItemId) {
        FoldersView()
          .environment(\.allItems, allItems)
      }
    } content: {
      if let selectedItemId = selectedItemId,
         let selectedItem = allItems.first(where: { $0.id == selectedItemId }) {
        switch selectedItem {
        case .folder(let folder):
          Text(folder.name)
        case .file(let file):
          RequestDetailView(request: file.request)
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
