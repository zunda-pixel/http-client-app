import Foundation
import Tagged

struct Folder: Identifiable, Hashable, Sendable {
  typealias ID = Tagged<Self, UUID>
  let id: ID = .init()
  var name: String
  var parentId: ID?
}

extension Folder {
  static let github = Self(name: "GitHub API")
  static let githubUsers = Self(name: "Users", parentId: github.id)
  static let githubRepositories = Self(name: "Repositories", parentId: github.id)
  static let google = Self(name: "Google API")
  static let googleAuth = Self(name: "Authentication", parentId: google.id)
  static let weather = Self(name: "Weather API")
  static let aws = Self(name: "AWS API")
}
