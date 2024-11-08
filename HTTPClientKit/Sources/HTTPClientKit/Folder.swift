import Foundation
import SwiftData

@Model
final public class Folder: Identifiable, Hashable, @unchecked Sendable {
  public typealias ID = UUID
  public var id: ID
  var name: String
  var parentId: ID?
  
  init(
    name: String,
    parentId: ID? = nil
  ) {
    self.id = .init()
    self.name = name
    self.parentId = parentId
  }
}

extension Folder {
  static let github = Folder(name: "GitHub API")
  static let githubUsers = Folder(name: "Users", parentId: github.id)
  static let githubRepositories = Folder(name: "Repositories", parentId: github.id)
  static let google = Folder(name: "Google API")
  static let googleAuth = Folder(name: "Authentication", parentId: google.id)
  static let weather = Folder(name: "Weather API")
  static let aws = Folder(name: "AWS API")
}
