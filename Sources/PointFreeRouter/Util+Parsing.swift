import Parsing

extension RawRepresentable {
  @inlinable
  public static func _parser(
    of inputType: RawValue.Type = RawValue.self
  ) -> Parsers._RawRepresentableParser<Self> {
    .init()
  }
}

extension RawRepresentable where RawValue == String {
  @inlinable
  public static func _parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.StringParser<Substring.UTF8View>>,
    Parsers._RawRepresentableParser<Self>
  > {
    String.parser(of: Substring.self).pipe(Self._parser())
  }

  @inlinable
  public static func _parser(
    of inputType: Substring.UTF8View.Type = Substring.UTF8View.self
  ) -> Parsers.Pipe<
    Parsers.StringParser<Substring.UTF8View>, Parsers._RawRepresentableParser<Self>
  > {
    String.parser(of: Substring.UTF8View.self).pipe(Self._parser())
  }
}

extension Parsers {
  public struct _RawRepresentableParser<Output>: Parser
  where
    Output: RawRepresentable
  {
    @inlinable
    public init() {}

    @inlinable
    public func parse(_ input: inout Output.RawValue) -> Output? {
      .init(rawValue: input)
    }
  }
}

extension Parsers._RawRepresentableParser: Printer {
  @inlinable
  public func print(_ output: Output) -> Output.RawValue? {
    output.rawValue
  }
}
