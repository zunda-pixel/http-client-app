import Foundation
import HTTPTypes

struct HTTPResult {
  var startTime: Date
  var endTime: Date
  var result: Result<(data: Data, response: HTTPResponse), any Error>
}
