import Observation

#if !os(macOS)
  @Observable
  final class NavigationRouter {
    var routes: [Route] = []

    enum Route: Hashable {
      case request(Request)
      case requestResult(HTTPResult)
    }
  }
#endif
