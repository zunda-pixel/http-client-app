import Foundation

struct Folder: Identifiable, Hashable, Sendable {
  let id: UUID = UUID()
  var name: String
  var parentId: UUID?
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
