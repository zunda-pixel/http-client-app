import Foundation
import HTTPTypes
import HTTPTypesFoundation
import Tagged

struct Request: Sendable, Hashable, Identifiable, Codable {
  typealias ID = UUID
  var id: ID = .init()
  var name: String
  var createdAt: Date = .now
  var updatedAt: Date = .now
  var method: HTTPRequest.Method = .get
  var baseUrl: String
  var queries: [URLQueryItem] = []

  var url: URL? {
    if queries.isEmpty {
      URL(string: baseUrl)
    } else {
      URL(string: baseUrl)?.appending(queryItems: queries)
    }
  }

  var httpRequest: HTTPRequest? {
    guard let url else { return nil }

    return HTTPRequest(
      method: method,
      url: url,
      headerFields: headerFields
    )
  }
  var headerFields: HTTPFields = [:]
  var body: Data? = nil
}

extension HTTPRequest.Method: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    if let method = Self(rawValue: rawValue) {
      self = method
    } else {
      throw DecodingError.dataCorrupted(.init(codingPath: container.codingPath, debugDescription: "Invalid method: \(rawValue)"))
    }
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

extension URLQueryItem: Codable {
  private enum CodingKeys: String, CodingKey {
    case name
    case value
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let name = try container.decode(String.self, forKey: .name)
    let value = try container.decodeIfPresent(String.self, forKey: .value)
    self.init(name: name, value: value)
  }
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(value, forKey: .value)
  }
}
