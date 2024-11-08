import Foundation
import HTTPTypes
import HTTPTypesFoundation
import Tagged

struct Request: Sendable, Hashable, Identifiable {
  typealias ID = Tagged<Self, UUID>
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
