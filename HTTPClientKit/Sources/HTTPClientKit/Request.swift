import Foundation
import HTTPTypes
import HTTPTypesFoundation

struct Request: Sendable, Hashable, Identifiable, Codable {
  typealias ID = UUID
  var id: ID = .init()
  var name: String
  var createdAt: Date = .now
  var updatedAt: Date = .now
  var method: HTTPRequest.Method = .get
  var baseUrl: String
  var paths: [IdentifiedItem<String>] = []
  var queries: [IdentifiedItem<KeyValue<String, String>>] = []

  var url: URL? {
    let queries = queries.map(\.item).map { URLQueryItem(name: $0.key, value: $0.value) }
    
    let url = if queries.isEmpty {
      URL(string: baseUrl)
    } else {
      URL(string: baseUrl)?.appending(queryItems: queries)
    }
    
    guard var url else { return nil }
    
    for path in paths {
      url.append(path: path.item)
    }
    
    return url
  }

  var httpRequest: HTTPRequest? {
    guard let url else { return nil }
    
    let headerFields: HTTPFields = headerFields.map(\.item).reduce(into: [:]) { items, item in
      guard let key = HTTPField.Name(item.key) else { return }
      items[key] = item.value
    }
    
    return HTTPRequest(
      method: method,
      url: url,
      headerFields: headerFields
    )
  }
  var headerFields: [IdentifiedItem<KeyValue<String, String>>] = []
  var useBody = false
  var body: Data? = nil
  var encoding: BodyEncoding = .utf8
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
