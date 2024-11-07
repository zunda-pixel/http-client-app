import Foundation

struct File: Identifiable, Hashable, Sendable {
  var request: Request
  var id: UUID { request.id }
  var folderId: Folder.ID?
}

extension File {
  static let githubUsersGet = Self(request: .init(name: "Get Users"), folderId: Folder.githubUsers.id)
  static let githubRepositoriesGet = Self(request: .init(name: "Get Repositories"), folderId: Folder.githubRepositories.id)
  static let googleAuthGet = Self(request: .init(name: "Get Auth"), folderId: Folder.googleAuth.id)
}
