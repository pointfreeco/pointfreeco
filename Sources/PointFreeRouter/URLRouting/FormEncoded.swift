import Foundation
import Parsing
import UrlFormEncoding

extension Conversion {
  @inlinable
  public static func form<Value>(
    _ type: Value.Type,
    decoder: UrlFormDecoder = .init()
  ) -> Self where Self == FormCoding<Value> {
    .init(type, decoder: decoder)
  }

  @inlinable
  public func form<Value>(
    _ type: Value.Type,
    decoder: UrlFormDecoder = .init()
  ) -> Conversions.Map<Self, FormCoding<Value>> {
    self.map(.form(type, decoder: decoder))
  }
}

public struct FormCoding<Value: Codable>: Conversion {
  public let decoder: UrlFormDecoder

  @inlinable
  public init(
    _ type: Value.Type,
    decoder: UrlFormDecoder = .init()
  ) {
    self.decoder = decoder
  }

  @inlinable
  public func apply(_ input: Data) throws -> Value {
    try decoder.decode(Value.self, from: input)
  }

  @inlinable
  public func unapply(_ output: Value) -> Data {
    Data(urlFormEncode(value: output).utf8)
  }
}
