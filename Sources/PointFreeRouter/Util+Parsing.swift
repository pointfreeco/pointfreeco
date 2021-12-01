import Foundation
import Parsing

extension RawRepresentable {
  @inlinable
  public static func parser(
    of inputType: RawValue.Type = RawValue.self
  ) -> Parsers._RawRepresentableParser<Self> {
    .init()
  }
}

extension RawRepresentable where RawValue == Bool {
  @inlinable
  public static func parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.BoolParser<Substring.UTF8View>>,
    Parsers._RawRepresentableParser<Self>
  > {
    RawValue.parser(of: Substring.self).pipe(Self.parser())
  }
}

extension RawRepresentable where RawValue == Double {
  @inlinable
  public static func parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.DoubleParser<Substring.UTF8View>>,
    Parsers._RawRepresentableParser<Self>
  > {
    RawValue.parser(of: Substring.self).pipe(Self.parser())
  }
}

extension RawRepresentable where RawValue == Float {
  @inlinable
  public static func parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.FloatParser<Substring.UTF8View>>,
    Parsers._RawRepresentableParser<Self>
  > {
    RawValue.parser(of: Substring.self).pipe(Self.parser())
  }
}

#if !(os(Windows) || os(Android)) && (arch(i386) || arch(x86_64))
  extension RawRepresentable where RawValue == Float80 {
    @inlinable
    public static func parser(
      of inputType: Substring.Type = Substring.self
    ) -> Parsers.Pipe<
      Parsers.UTF8ViewToSubstring<Parsers.Float80Parser<Substring.UTF8View>>,
      Parsers._RawRepresentableParser<Self>
    > {
      RawValue.parser(of: Substring.self).pipe(Self.parser())
    }
  }
#endif

extension RawRepresentable where RawValue: FixedWidthInteger {
  @inlinable
  public static func parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.IntParser<Substring.UTF8View, RawValue>>,
    Parsers._RawRepresentableParser<Self>
  > {
    RawValue.parser(of: Substring.self).pipe(Self.parser())
  }
}

extension RawRepresentable where RawValue == String {
  @inlinable
  public static func parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.StringParser<Substring.UTF8View>>,
    Parsers._RawRepresentableParser<Self>
  > {
    RawValue.parser(of: Substring.self).pipe(Self.parser())
  }
}

extension RawRepresentable where RawValue == UUID {
  @inlinable
  public static func parser(
    of inputType: Substring.Type = Substring.self
  ) -> Parsers.Pipe<
    Parsers.UTF8ViewToSubstring<Parsers.UUIDParser<Substring.UTF8View>>,
    Parsers._RawRepresentableParser<Self>
  > {
    RawValue.parser(of: Substring.self).pipe(Self.parser())
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
