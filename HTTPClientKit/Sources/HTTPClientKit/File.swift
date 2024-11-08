import Foundation
import Tagged

struct File: Identifiable, Hashable, Sendable {
  typealias ID = Tagged<Self, UUID>
  var request: Request
  var id: ID { .init(request.id.rawValue) }
  var folderId: Folder.ID?
}

extension File {
  static let githubUsersGet = Self(
    request: .init(name: "Users", method: .get, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubUsersPost = Self(
    request: .init(name: "Users", method: .post, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubUsersDelete = Self(
    request: .init(name: "Users", method: .delete, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubUsersPut = Self(
    request: .init(name: "Users", method: .put, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubRepositoriesGet = Self(
    request: .init(name: "Repositories", method: .get, baseUrl: "https://api.github.com/repositories"),
    folderId: Folder.githubRepositories.id
  )
  static let googleAuthGet = Self(
    request: .init(name: "Auth", method: .get, baseUrl: "https://accounts.google.com/auth"),
    folderId: Folder.googleAuth.id
  )
}
