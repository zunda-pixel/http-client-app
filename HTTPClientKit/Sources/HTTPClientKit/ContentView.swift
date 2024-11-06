import SwiftUI

public struct ContentView: View {
  @State var resultState: ResultState = .init()
  @State var router = NavigationRouter()
  @State var selectedRequest: Request?
  @State var requests: [Request] = [
    .init(name: "Name1"),
    .init(name: "Name2"),
    .init(name: "Name3")
  ]
  
  public init() { }

  public var body: some View {
    NavigationSplitView {
      List(requests, selection: $selectedRequest) { request in
        RequestCell(request: request)
          .id(request)
      }
    } content: {
      NavigationStack(path: $router.items) {
        if let request = selectedRequest {
          RequestDetailView(request: request)
            .navigationDestination(for: NavigationRouter.Item.self) { item in
              switch item {
              case .requestDetail(let request):
                RequestDetailView(request: request)
              }
            }
        }
      }
      .environment(router)
    } detail: {
      if let result = resultState.result {
        ResultDetailView(result: result)
      }
    }
    .environment(resultState)
  }
}
