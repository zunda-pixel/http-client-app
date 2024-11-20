import Foundation
import HTTPTypes
import Observation

#if os(macOS)
  @Observable
  final class ResultState {
    var result: HTTPResult?
  }
#endif
