import Observation
import HTTPTypes
import Foundation

@Observable
final class NavigationRouter {
  var items: [Item] = []
  
  enum Item: Hashable {
    case requestDetail(request: Request)
  }
}
