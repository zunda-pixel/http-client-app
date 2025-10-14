import Foundation
import HTTPTypes

struct HTTPResult: Hashable {
  var startTime: Date
  var endTime: Date
  var result: Result<(data: Data, response: HTTPResponse), any Error>

  static func == (lhs: HTTPResult, rhs: HTTPResult) -> Bool {
    switch lhs.result {
    case .success(let successLhs):
      switch rhs.result {
      case .success(let successRhs):
        return successLhs.data == successRhs.data && successLhs.response == successRhs.response
      case .failure(_):
        return false
      }
    case .failure(let failureLhs):
      switch rhs.result {
      case .success(_):
        return false
      case .failure(let failureRhs):
        return failureLhs.localizedDescription == failureRhs.localizedDescription
      }
    }
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(startTime)
    hasher.combine(endTime)
    switch result {
    case .success(let success):
      hasher.combine(success.data)
      hasher.combine(success.response)
    case .failure(let failure):
      hasher.combine(failure.localizedDescription)
    }
  }
}
