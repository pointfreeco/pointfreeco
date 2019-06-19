import Foundation
import PostgresNIO
import PostgreSQL
import Prelude

public struct ColumnDecoder: Decoder {
  public let codingPath: [CodingKey] = []
  public let column: PostgresData
  public let userInfo: [CodingUserInfoKey: Any] = [:]

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    fatalError("Column decoder can't decode keyed values")
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    fatalError("Column decoder can't decode unkeyed values")
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return SingleValueContainer(column: column)
  }

  struct SingleValueContainer: SingleValueDecodingContainer {
    let codingPath: [CodingKey] = []
    let column: PostgresData

    func decodeNil() -> Bool { column.type == .null }
    func decode(_ type: Bool.Type) throws -> Bool { column.bool! }
    func decode(_ type: String.Type) throws -> String { column.string! }
    func decode(_ type: Double.Type) throws -> Double { column.double! }
    func decode(_ type: Float.Type) throws -> Float { column.float! }
    func decode(_ type: Int.Type) throws -> Int { column.int! }
    func decode(_ type: Int8.Type) throws -> Int8 { column.int8! }
    func decode(_ type: Int16.Type) throws -> Int16 { column.int16! }
    func decode(_ type: Int32.Type) throws -> Int32 { column.int32! }
    func decode(_ type: Int64.Type) throws -> Int64 { column.int64! }
    func decode(_ type: UInt.Type) throws -> UInt { column.uint! }
    func decode(_ type: UInt8.Type) throws -> UInt8 { column.uint8! }
    func decode(_ type: UInt16.Type) throws -> UInt16 { column.uint16! }
    func decode(_ type: UInt32.Type) throws -> UInt32 { column.uint32! }
    func decode(_ type: UInt64.Type) throws -> UInt64 { column.uint64! }
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      fatalError()
    }
  }
}

public struct RowDecoder: Decoder {
  public let codingPath: [CodingKey] = []
  public let row: PostgresRow
  public let userInfo: [CodingUserInfoKey: Any] = [:]

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
    KeyedDecodingContainer(KeyedContainer(row: self.row))
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    fatalError("Row decoder can't decode unkeyed values")
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    fatalError("Row decoder can't decode single values")
  }

  private struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let allKeys: [Key] = []
    let codingPath: [CodingKey] = []
    let row: PostgresRow

    func contains(_ key: Key) -> Bool {
      row.column(key.stringValue) != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      row.column(key.stringValue)?.type == .null
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      row.column(key.stringValue)!.bool!
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      row.column(key.stringValue)!.string!
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      row.column(key.stringValue)!.double!
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      row.column(key.stringValue)!.float!
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      row.column(key.stringValue)!.int!
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      row.column(key.stringValue)!.int8!
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      row.column(key.stringValue)!.int16!
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      row.column(key.stringValue)!.int32!
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      row.column(key.stringValue)!.int64!
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      row.column(key.stringValue)!.uint!
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      row.column(key.stringValue)!.uint8!
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      row.column(key.stringValue)!.uint16!
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      row.column(key.stringValue)!.uint32!
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      row.column(key.stringValue)!.uint64!
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
      try T(from: ColumnDecoder(column: row.column(key.stringValue)!))
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
      fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      fatalError()
    }

    func superDecoder() throws -> Decoder {
      fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
      fatalError()
    }
  }
}

public final class DatabaseDecoder: Decoder {
  private(set) var containers: [PostgreSQL.Node] = []
  private var container: PostgreSQL.Node {
    return containers.last!
  }

  public private(set) var codingPath: [CodingKey] = []
  public let userInfo: [CodingUserInfoKey: Any] = [:]

  public init() {
  }

  public func decode<T: Decodable>(_ type: T.Type, from node: Node) throws -> T {
    self.containers.append(node)
    defer { self.containers.removeLast() }
    if type == Date.self {
      guard let date = node.date else {
        throw Error.decodingError("Expected Date, got \(node)", self.codingPath)
      }
      return date as! T
    } else {
      return try T(from: self)
    }
  }

  public func container<Key>(keyedBy type: Key.Type) throws
    -> KeyedDecodingContainer<Key>
    where Key: CodingKey {

      guard let container = self.container.object else {
        throw Error.decodingError("Expected keyed container, got \(self.container)", self.codingPath)
      }
      return .init(KeyedContainer(decoder: self, container: container))
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    guard let container = self.container.array else {
      throw Error.decodingError("Expected unkeyed container, got \(self.container)", self.codingPath)
    }
    return UnkeyedContainer(decoder: self, container: container, codingPath: self.codingPath)
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    return SingleValueContainer(decoder: self, container: self.container)
  }

  public enum Error: Swift.Error {
    case decodingError(String, [CodingKey])
  }

  struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    private(set) var decoder: DatabaseDecoder
    let container: [String: PostgreSQL.Node]

    var codingPath: [CodingKey] {
      return self.decoder.codingPath
    }
    var allKeys: [Key] {
      return self.container.keys.compactMap(Key.init(stringValue:))
    }

    private func checked<T>(_ key: Key, _ block: (PostgreSQL.Node) throws -> T) throws -> T {
      guard let value = self.container[key.stringValue] else {
        throw Error.decodingError("Expected \(T.self) at \(key), got nil", self.codingPath)
      }
      return try block(value)
    }

    private func unwrap<T>(_ key: Key, _ block: (PostgreSQL.Node) -> T?) throws -> T {
      guard let value = try self.checked(key, block) else {
        throw Error.decodingError("Expected \(T.self) at \(key), got nil", self.codingPath)
      }
      return value
    }

    func contains(_ key: Key) -> Bool {
      return self.container[key.stringValue] != nil
    }

    func decodeNil(forKey key: Key) throws -> Bool {
      return try self.checked(key, ^\.isNull)
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
      return try self.unwrap(key, ^\.bool)
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
      return try self.unwrap(key, ^\.int)
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
      return try self.unwrap(key, ^\.int >=> Int8.init)
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
      return try self.unwrap(key, ^\.int >=> Int16.init)
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
      return try self.unwrap(key, ^\.int >=> Int32.init)
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
      return try self.unwrap(key, ^\.int >=> Int64.init)
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
      return try self.unwrap(key, ^\.uint)
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
      return try self.unwrap(key, ^\.uint >=> UInt8.init)
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
      return try self.unwrap(key, ^\.uint >=> UInt16.init)
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
      return try self.unwrap(key, ^\.uint >=> UInt32.init)
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
      return try self.unwrap(key, ^\.uint >=> UInt64.init)
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
      return try self.unwrap(key, ^\.float)
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
      return try self.unwrap(key, ^\.double)
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
      return try self.unwrap(key, ^\.string)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
      self.decoder.codingPath.append(key)
      defer { self.decoder.codingPath.removeLast() }
      guard let container = self.container[key.stringValue] else {
        throw Error.decodingError("Expected \(T.self) at \(key), got nil", self.codingPath)
      }
      return try self.decoder.decode(T.self, from: container)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws
      -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        self.decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }
        guard let value = self.container[key.stringValue], let container = value.object else {
          throw Error.decodingError("Expected value at \(key), got nil", self.codingPath)
        }
        return .init(KeyedContainer<NestedKey>(decoder: self.decoder, container: container))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
      self.decoder.codingPath.append(key)
      defer { self.decoder.codingPath.removeLast() }
      guard let value = self.container[key.stringValue], let container = value.array else {
        throw Error.decodingError("Expected value at \(key), got nil", self.codingPath)
      }
      return UnkeyedContainer(decoder: self.decoder, container: container, codingPath: self.codingPath)
    }

    func superDecoder() throws -> Decoder {
      fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
      self.decoder.codingPath.append(key)
      defer { self.decoder.codingPath.removeLast() }
      guard let container = self.container[key.stringValue] else {
        throw Error.decodingError("Expected value at \(key), got nil", self.codingPath)
      }
      let decoder = DatabaseDecoder()
      decoder.containers = [container]
      decoder.codingPath = self.codingPath
      return decoder
    }
  }

  struct UnkeyedContainer: UnkeyedDecodingContainer {
    struct Key {
      let index: Int
    }

    let decoder: DatabaseDecoder
    let container: [PostgreSQL.Node]

    private(set) var codingPath: [CodingKey]
    var count: Int? {
      return self.container.count
    }
    var isAtEnd: Bool {
      return self.currentIndex >= self.container.count
    }
    private(set) var currentIndex: Int = 0

    init(decoder: DatabaseDecoder, container: [PostgreSQL.Node], codingPath: [CodingKey]) {
      self.decoder = decoder
      self.container = container
      self.codingPath = codingPath
    }

    mutating private func checked<T>(_ block: (PostgreSQL.Node) throws -> T) throws -> T {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      let value = try block(self.container[self.currentIndex])
      self.currentIndex += 1
      return value
    }

    mutating private func unwrap<T>(_ block: (PostgreSQL.Node) -> T?) throws -> T {
      guard let value = try self.checked(block) else {
        throw Error.decodingError("Expected \(T.self) at \(self.currentIndex), got nil", self.codingPath)
      }
      return value
    }

    mutating func decodeNil() throws -> Bool {
      return try self.checked(^\.isNull)
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
      return try self.unwrap(^\.bool)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
      return try self.unwrap(^\.int)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
      return try self.unwrap(^\.int >=> Int8.init)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
      return try self.unwrap(^\.int >=> Int16.init)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
      return try self.unwrap(^\.int >=> Int32.init)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
      return try self.unwrap(^\.int >=> Int64.init)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
      return try self.unwrap(^\.uint)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
      return try self.unwrap(^\.uint >=> UInt8.init)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
      return try self.unwrap(^\.uint >=> UInt16.init)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
      return try self.unwrap(^\.uint >=> UInt32.init)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
      return try self.unwrap(^\.uint >=> UInt64.init)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
      return try self.unwrap(^\.float)
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
      return try self.unwrap(^\.double)
    }

    mutating func decode(_ type: String.Type) throws -> String {
      return try self.unwrap(^\.string)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      let container = self.container[self.currentIndex]
      self.currentIndex += 1
      return try self.decoder.decode(T.self, from: container)
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
      -> KeyedDecodingContainer<NestedKey>
      where NestedKey: CodingKey {

        guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
        self.codingPath.append(Key(index: self.currentIndex))
        defer { self.codingPath.removeLast() }
        guard let container = self.container[self.currentIndex].object else {
          throw Error.decodingError("Expected value at \(self.currentIndex), got nil", self.codingPath)
        }
        self.currentIndex += 1
        return .init(KeyedContainer(decoder: self.decoder, container: container))
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      guard let container = self.container[self.currentIndex].array else {
        throw Error.decodingError("Expected value at \(self.currentIndex), got nil", self.codingPath)
      }
      self.currentIndex += 1
      return UnkeyedContainer(decoder: self.decoder, container: container, codingPath: self.codingPath)
    }

    mutating func superDecoder() throws -> Decoder {
      guard !self.isAtEnd else { throw Error.decodingError("Unkeyed container is at end", self.codingPath) }
      self.codingPath.append(Key(index: self.currentIndex))
      defer { self.codingPath.removeLast() }
      let container = self.container[self.currentIndex]
      self.currentIndex += 1
      let decoder = DatabaseDecoder()
      decoder.containers = [container]
      decoder.codingPath = self.codingPath
      return decoder
    }
  }

  struct SingleValueContainer: SingleValueDecodingContainer {
    let decoder: DatabaseDecoder
    let container: PostgreSQL.Node

    let codingPath: [CodingKey] = []

    private func unwrap<T>(_ block: (PostgreSQL.Node) -> T?, _ line: UInt = #line) throws -> T {
      guard let value = block(self.container) else {
        throw Error.decodingError("Expected \(T.self), got nil", self.codingPath)
      }
      return value
    }

    func decodeNil() -> Bool {
      return self.container.isNull
    }

    func decode(_ type: Bool.Type) throws -> Bool {
      return try self.unwrap(^\.bool)
    }

    func decode(_ type: Int.Type) throws -> Int {
      return try self.unwrap(^\.int)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
      return try self.unwrap(^\.int >=> Int8.init)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
      return try self.unwrap(^\.int >=> Int16.init)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
      return try self.unwrap(^\.int >=> Int32.init)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
      return try self.unwrap(^\.int >=> Int64.init)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
      return try self.unwrap(^\.uint)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
      return try self.unwrap(^\.uint >=> UInt8.init)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
      return try self.unwrap(^\.uint >=> UInt16.init)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
      return try self.unwrap(^\.uint >=> UInt32.init)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
      return try self.unwrap(^\.uint >=> UInt64.init)
    }

    func decode(_ type: Float.Type) throws -> Float {
      return try self.unwrap(^\.float)
    }

    func decode(_ type: Double.Type) throws -> Double {
      return try self.unwrap(^\.double)
    }

    func decode(_ type: String.Type) throws -> String {
      return try self.unwrap(^\.string)
    }

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
      return try self.decoder.decode(T.self, from: self.container)
    }
  }
}

extension DatabaseDecoder.UnkeyedContainer.Key: CodingKey {
  public var stringValue: String {
    return String(self.index)
  }

  public init?(stringValue: String) {
    guard let intValue = Int(stringValue) else { return nil }
    self.init(intValue: intValue)
  }

  public var intValue: Int? {
    return .some(self.index)
  }

  public init?(intValue: Int) {
    self.init(index: intValue)
  }
}
