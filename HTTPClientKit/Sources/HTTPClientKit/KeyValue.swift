struct KeyValue<Key, Value> {
  var key: Key
  var value: Value
  var isOn: Bool
}

extension KeyValue: Codable where Key: Codable, Value: Codable {}
extension KeyValue: Equatable where Key: Equatable, Value: Equatable {}
extension KeyValue: Hashable where Key: Hashable, Value: Hashable {}
extension KeyValue: Sendable where Key: Sendable, Value: Sendable {}
