import Foundation
import PostgresNIO
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
    return SingleValueContainer(column: self.column)
  }

  struct SingleValueContainer: SingleValueDecodingContainer {
    let codingPath: [CodingKey] = []
    let column: PostgresData

    func decodeNil() -> Bool { column.type == .null }
    func decode(_ type: Bool.Type) throws -> Bool { column.bool! }
    func decode(_ type: String.Type) throws -> String { String(decoding: column.bytes!, as: UTF8.self) } // { column.string! }
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
      try T(from: ColumnDecoder(column: self.column))
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
