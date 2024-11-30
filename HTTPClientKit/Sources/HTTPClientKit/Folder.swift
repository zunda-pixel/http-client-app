import Foundation
import SwiftData

@Model
final public class Folder: Identifiable, Hashable, @unchecked Sendable {
  public typealias ID = UUID
  @Attribute(.unique) public var id: ID
  var name: String
  var childrenIds: [UUID] = []
  init(
    name: String,
    childrenIds: [UUID] = []
  ) {
    self.id = .init()
    self.name = name
    self.childrenIds = childrenIds
  }
}
