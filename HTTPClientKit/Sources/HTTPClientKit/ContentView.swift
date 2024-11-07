import SwiftUI

public struct ContentView: View {
  @State var resultState: ResultState = .init()
  @State var selectedItemId: Item.ID?
  @State var itemController = ItemController()
  
  public init() { }

  public var body: some View {
    NavigationSplitView {
      List(selection: $selectedItemId) {
        FoldersView()
          .environment(\.allItems, itemController.items)
      }
    } content: {
      if let selectedItemId = selectedItemId,
         let selectedItem = itemController.items.first(where: { $0.id == selectedItemId }) {
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
    .environment(itemController)
  }
}
