import Foundation
import Parsing

public struct URLRequestData: Equatable {
  public var body: ArraySlice<UInt8>?
  public var headers: [String: Substring]
  public var method: String?
  public var path: ArraySlice<Substring>
  public var query: [String: ArraySlice<Substring?>]

  public init(
    method: String? = nil,
    path: ArraySlice<Substring> = [],
    query: [String: ArraySlice<Substring?>] = [:],
    headers: [String: Substring] = [:],
    body: ArraySlice<UInt8>? = nil
  ) {
    self.method = method
    self.path = path
    self.query = query
    self.headers = headers
    self.body = body
  }
}

extension URLRequestData: Appendable {
  public init() {
    self.init(method: nil, path: [], query: [:], headers: [:], body: nil)
  }

  public mutating func append(contentsOf other: URLRequestData) {
    if let body = other.body {
      if self.body != nil {
        self.body?.append(contentsOf: other.body ?? [])
      } else {
        self.body = body
      }
    }
    self.headers.merge(other.headers, uniquingKeysWith: { lhs, rhs in lhs })
    self.method = self.method ?? other.method
    self.path.append(contentsOf: other.path)
    self.query.merge(other.query, uniquingKeysWith: +)
  }
}

public struct Body<BodyParser>: Parser
where
  BodyParser: Parser,
  BodyParser.Input == ArraySlice<UInt8>
{
  public let bodyParser: BodyParser

  @inlinable
  public init(@ParserBuilder _ bodyParser: () -> BodyParser) {
    self.bodyParser = bodyParser()
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> BodyParser.Output? {
    guard
      var body = input.body,
      let output = self.bodyParser.parse(&body),
      body.isEmpty
    else { return nil }

    input.body = nil
    return output
  }
}

extension Body: Printer where BodyParser: Printer {
  public func print(_ output: BodyParser.Output) -> URLRequestData? {
    self.bodyParser.print(output).map { .init(body: $0) }
  }
}

public struct JSON<Value: Decodable>: Parser {
  public let decoder: JSONDecoder
  public let encoder: JSONEncoder

  @inlinable
  public init(
    _ type: Value.Type,
    decoder: JSONDecoder = .init(),
    encoder: JSONEncoder = .init()
  ) {
    self.decoder = decoder
    self.encoder = encoder
  }

  @inlinable
  public func parse(_ input: inout ArraySlice<UInt8>) -> Value? {
    guard
      let output = try? self.decoder.decode(Value.self, from: Data(input))
    else { return nil }
    input = []
    return output
  }
}

extension JSON: Printer where Value: Encodable {
  @inlinable
  public func print(_ output: Value) -> ArraySlice<UInt8>? {
    guard
      let input = try? self.encoder.encode(output)
    else { return nil }
    return .init(input)
  }
}

public struct Method: Parser {
  public let name: String

  public static let get = OneOf {
    Self("GET")
    Self("HEAD")
  }
  public static let post = Self("POST")
  public static let put = Self("PUT")
  public static let patch = Self("PATCH")
  public static let delete = Self("DELETE")

  @inlinable
  public init(_ name: String) {
    self.name = name.uppercased()
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Void? {
    guard input.method?.uppercased() == self.name else { return nil }
    input.method = nil
    return ()
  }
}

extension Method: Printer {
  @inlinable
  public func print(_ output: Void) -> URLRequestData? {
    .init(method: self.name)
  }
}

public struct Path<ComponentParser>: Parser
where
  ComponentParser: Parser,
  ComponentParser.Input == Substring
{
  public let componentParser: ComponentParser

  @inlinable
  public init(_ component: ComponentParser) {
    self.componentParser = component
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> ComponentParser.Output? {
    guard
      var component = input.path.first,
      let output = self.componentParser.parse(&component),
      component.isEmpty
    else { return nil }

    input.path.removeFirst()
    return output
  }
}

extension Path: Printer where ComponentParser: Printer {
  public func print(_ output: ComponentParser.Output) -> URLRequestData? {
    self.componentParser.print(output).map { .init(path: [$0]) }
  }
}

public struct PathEnd: Parser {
  @inlinable
  public init() {}

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Void? {
    guard input.path.isEmpty
    else { return nil }
    return ()
  }
}

extension PathEnd: Printer {
  @inlinable
  public func print(_ output: Void) -> URLRequestData? {
    .init()
  }
}

public struct Query<ValueParser>: Parser
where
  ValueParser: Parser,
  ValueParser.Input == Substring
{
  public let defaultValue: ValueParser.Output?
  public let name: String
  public let valueParser: ValueParser

  @inlinable
  public init(
    _ name: String,
    _ value: ValueParser,
    default defaultValue: ValueParser.Output? = nil
  ) {
    self.defaultValue = defaultValue
    self.name = name
    self.valueParser = value
  }

  @inlinable
  public init(
    _ name: String,
    default defaultValue: ValueParser.Output? = nil
  ) where ValueParser == Rest<Substring> {
    self.init(
      name,
      Rest(),
      default: defaultValue
    )
  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> ValueParser.Output? {
    guard
      let wrapped = input.query[self.name]?.first,
      var value = wrapped,
      let output = self.valueParser.parse(&value),
      value.isEmpty
    else { return defaultValue }

    input.query[self.name]?.removeFirst()
    if input.query[self.name]?.isEmpty ?? true {
      input.query[self.name] = nil
    }
    return output
  }
}

extension Query: Printer where ValueParser: Printer {
  @inlinable
  public func print(_ output: ValueParser.Output) -> URLRequestData? {
    if let defaultValue = self.defaultValue, isEqual(output, defaultValue) { return .init() }
    return self.valueParser.print(output).map { .init(query: [self.name: [$0]]) }
  }
}

public struct Routing<RouteParser, Route>: Parser
where
  RouteParser: Parser,
  RouteParser.Input == URLRequestData
{
  public
  let parser: Zip2_OV<Parsers.Pipe<RouteParser, CasePath<Route, RouteParser.Output>>, PathEnd>

  @inlinable
  public init(
    _ route: CasePath<Route, RouteParser.Output>,
    @ParserBuilder to parser: () -> RouteParser
  ) {
    self.parser = ParserBuilder.buildBlock(parser().pipe(route), PathEnd())
  }

//  @inlinable
//  init(
//    _ route: CasePath<Route, RouteParser.Output>
//  ) where RouteParser == Always<URLRequestData, Void> {
//    self.init(route, to: { Always<URLRequestData, Void>(()) })
//  }

  @inlinable
  public func parse(_ input: inout URLRequestData) -> Route? {
    self.parser.parse(&input)
  }
}

extension Routing: Printer where RouteParser: Printer {
  @inlinable
  public func print(_ output: Route) -> URLRequestData? {
    self.parser.print(output)
  }
}

// MARK: -

private enum Box<T> {}

private protocol AnyEquatable {
  static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

extension Box: AnyEquatable where T: Equatable {
  fileprivate static func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    lhs as? T == rhs as? T
  }
}

@usableFromInline
func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  func open<LHS>(_: LHS.Type) -> Bool? {
    (Box<LHS>.self as? AnyEquatable.Type)?.isEqual(lhs, rhs)
  }
  return _openExistential(type(of: lhs), do: open) ?? false
}
