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
}
