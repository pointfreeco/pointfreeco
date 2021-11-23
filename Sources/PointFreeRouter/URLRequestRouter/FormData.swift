import Foundation
import Parsing
import UrlFormEncoding

public struct FormData<Value>: Parser where Value: Decodable {
  public let decoder: UrlFormDecoder

  @inlinable
  public init(
    _ type: Value.Type,
    decoder: UrlFormDecoder = .init()
  ) {
    self.decoder = decoder
  }

  @inlinable
  public func parse(_ input: inout ArraySlice<UInt8>) -> Value? {
    guard
      let output = try? decoder.decode(Value.self, from: Data(input))
    else { return nil }
    input = [] // FIXME: Only consume decoded fields?
    return output
  }
}

extension FormData: Printer where Value: Encodable {
  @inlinable
  public func print(_ output: Value) -> ArraySlice<UInt8>? {
    return ArraySlice(urlFormEncode(value: output).utf8)
  }
}
