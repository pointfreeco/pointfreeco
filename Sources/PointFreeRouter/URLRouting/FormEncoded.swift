import Foundation
import Parsing
import UrlFormEncoding

// FIXME: This should be a conversion.

public struct FormCoded<Value>: Parser where Value: Decodable {
  public let decoder: UrlFormDecoder

  @inlinable
  public init(
    _ type: Value.Type,
    decoder: UrlFormDecoder = .init()
  ) {
    self.decoder = decoder
  }

  @inlinable
  public func parse(_ input: inout ArraySlice<UInt8>) throws -> Value {
    try decoder.decode(Value.self, from: Data(input))
  }
}

extension FormCoded: ParserPrinter where Value: Encodable {
  @inlinable
  public func print(_ output: Value, into input: inout ArraySlice<UInt8>) {
    input = ArraySlice(urlFormEncode(value: output).utf8)
  }
}
