import Foundation
import SwiftData

@Model
final public class Folder: Identifiable, Hashable, @unchecked Sendable {
  public typealias ID = UUID
  @Attribute(.unique) public var id: ID
  var name: String
  var childrenFolders: [Folder] = []
  var childrenRequests: [Request] = []
  
  init(
    name: String,
    childrenFolders: [Folder] = [],
    childrenRequests: [Request] = []
  ) {
    self.id = .init()
    self.name = name
    self.childrenFolders = childrenFolders
    self.childrenRequests = childrenRequests
  }
  
  private func createNewChildFolderName(prefix: String, suffix: Int) -> String {
    let name = "\(prefix)\(suffix)"
    if childrenFolders.contains(where: { $0.name == name }) {
      return createNewChildFolderName(prefix: prefix, suffix: suffix + 1)
    }
    return name
  }
  
  func createNewFolder() -> Folder {
    let name = createNewChildFolderName(prefix: "NewFolder", suffix: 1)
    return Folder(name: name)
  }
  
  private func createNewChildRequestName(prefix: String, suffix: Int) -> String {
    let name = "\(prefix)\(suffix)"
    if childrenRequests.contains(where: { $0.name == name }) {
      return createNewChildRequestName(prefix: prefix, suffix: suffix + 1)
    }
    return name
  }
  
  func createNewRequest() -> Request {
    let name = createNewChildRequestName(prefix: "NewRequest", suffix: 1)
    return Request(name: name, baseUrl: "https://apple.com")
  }
}
