import Foundation

enum BodyEncoding: String, Sendable, Codable, Hashable, CaseIterable {
  case utf8 = "UTF-8"
  case shiftJis = "Shift_JIS"

  var rawEncoding: String.Encoding {
    switch self {
    case .utf8: return .utf8
    case .shiftJis: return .shiftJIS
    }
  }
}
