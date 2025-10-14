import Foundation
import HTTPTypes
import HTTPTypesFoundation
import Observation
import SwiftData

@Model
public final class Request: @unchecked Sendable, Hashable {
  @Attribute(.unique) public var id = UUID()
  var name: String
  var createdAt: Date
  var updatedAt: Date
  var method: HTTPRequest.Method
  var baseUrl: String
  var paths: [IdentifiedItem<URLPath>]
  var queries: [IdentifiedItem<KeyValue<String, String>>]
  var headerFields: [IdentifiedItem<KeyValue<String, String>>]
  var useBody: Bool
  var body: Data?
  var encoding: BodyEncoding
  
  init(
    name: String,
    createdAt: Date = .now,
    updatedAt: Date = .now,
    method: HTTPRequest.Method = .get,
    baseUrl: String,
    paths: [IdentifiedItem<URLPath>] = [],
    queries: [IdentifiedItem<KeyValue<String,String>>] = [],
    headerFields: [IdentifiedItem<KeyValue<String, String>>] = [],
    useBody: Bool = false,
    body: Data? = nil,
    encoding: BodyEncoding = .utf8
  ) {
    self.name = name
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.method = method
    self.baseUrl = baseUrl
    self.paths = paths
    self.queries = queries
    self.headerFields = headerFields
    self.useBody = useBody
    self.body = body
    self.encoding = encoding
  }
  
  var url: URL? {
    let queries = queries.map(\.item).filter { $0.isOn }.map { URLQueryItem(name: $0.key, value: $0.value) }

    let url =
      if queries.isEmpty {
        URL(string: baseUrl)
      } else {
        URL(string: baseUrl)?.appending(queryItems: queries)
      }

    guard var url else { return nil }

    for path in paths where path.item.isOn {
      url.append(path: path.item.value)
    }

    return url
  }

  var httpRequest: HTTPRequest? {
    guard let url else { return nil }

    let headerFields: HTTPFields = headerFields.map(\.item).filter { $0.isOn }.reduce(into: [:]) { items, item in
      guard let key = HTTPField.Name(item.key) else { return }
      items[key] = item.value
    }

    return HTTPRequest(
      method: method,
      url: url,
      headerFields: headerFields
    )
  }
  
  func generateNewHeaerName(prefix: String, postfix: Int) -> String {
    let name = "\(prefix)\(postfix)"
    if headerFields.contains(where: { $0.item.key == name }) {
      return generateNewHeaerName(prefix: prefix, postfix: postfix + 1)
    }
    return name
  }
  
  func generateNewQueryName(prefix: String, postfix: Int) -> String {
    let name = "\(prefix)\(postfix)"
    if queries.contains(where: { $0.item.key == name }) {
      return generateNewQueryName(prefix: prefix, postfix: postfix + 1)
    }
    return name
  }
  
  private func addNewHeaderField() {
    let name = generateNewHeaerName(prefix: "NewHeader", postfix: 1)
    headerFields.append(IdentifiedItem(item: KeyValue(key: name, value: "Value", isOn: true)))
  }
  
  func addNewQuery() {
    let name = generateNewQueryName(prefix: "NewHeader", postfix: 1)
    queries.append(IdentifiedItem(item: KeyValue(key: name, value: "Value", isOn: true)))
  }
  
  func addNewHeader(header: NewHeader) {
    switch header {
    case .new:
      addNewHeaderField()
    case .authorization:
      headerFields.append(
        .init(item: .init(key: HTTPField.Name.authorization.rawName, value: "", isOn: true)))
    case .contentType:
      headerFields.append(
        .init(item: .init(key: HTTPField.Name.contentType.rawName, value: "", isOn: true)))
    }
  }
}

enum NewHeader: String, CaseIterable, Identifiable {
  var id: Self { self }

  case new = "New"
  case authorization = "Authorization"
  case contentType = "Content-Type"
}

extension HTTPRequest.Method: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    if let method = Self(rawValue: rawValue) {
      self = method
    } else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: container.codingPath, debugDescription: "Invalid method: \(rawValue)"))
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}
