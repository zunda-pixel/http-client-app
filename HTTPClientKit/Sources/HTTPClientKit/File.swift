import Foundation
import SwiftData

@Model
final public class File: Identifiable, Hashable, @unchecked Sendable {
  public typealias ID = UUID
  var request: Request
  @Attribute(.unique) public var id: ID
  
  init(
    request: Request
  ) {
    self.id = .init()
    self.request = request
  }
}
