import Observation

#if !os(macOS)
  @Observable
  final class NavigationRouter {
    var routes: [Route] = []

    enum Route: Hashable {
      case request(File)
      case requestResult(HTTPResult)
    }
  }
#endif
