import Foundation

struct IdentifiedItem<Item>: Identifiable {
  var id: UUID
  var item: Item

  init(id: UUID = UUID(), item: Item) {
    self.id = id
    self.item = item
  }
}

extension IdentifiedItem: Equatable where Item: Equatable {}
extension IdentifiedItem: Hashable where Item: Hashable {}
extension IdentifiedItem: Codable where Item: Codable {}
extension IdentifiedItem: Sendable where Item: Sendable {}
