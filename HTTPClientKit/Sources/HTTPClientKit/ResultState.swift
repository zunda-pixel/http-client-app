import Observation
import HTTPTypes
import Foundation

@Observable
final class ResultState {
  var result: (data: Data, response: HTTPResponse)?
}
