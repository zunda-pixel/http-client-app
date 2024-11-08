import Foundation
import SwiftData

@Model
final public class File: Identifiable, Hashable, @unchecked Sendable {
  public typealias ID = UUID
  var request: Request
  public var id: ID { request.id }
  var folderId: Folder.ID?
  
  init(
    request: Request,
    folderId: Folder.ID? = nil
  ) {
    self.request = request
    self.folderId = folderId
  }
}

extension File {
  static let githubUsersGet = File(
    request: .init(name: "Users", method: .get, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubUsersPost = File(
    request: .init(name: "Users", method: .post, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubUsersDelete = File(
    request: .init(name: "Users", method: .delete, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubUsersPut = File(
    request: .init(name: "Users", method: .put, baseUrl: "https://api.github.com/users"),
    folderId: Folder.githubUsers.id
  )
  static let githubRepositoriesGet = File(
    request: .init(name: "Repositories", method: .get, baseUrl: "https://api.github.com/repositories"),
    folderId: Folder.githubRepositories.id
  )
  static let googleAuthGet = File(
    request: .init(name: "Auth", method: .get, baseUrl: "https://accounts.google.com/auth"),
    folderId: Folder.googleAuth.id
  )
}
