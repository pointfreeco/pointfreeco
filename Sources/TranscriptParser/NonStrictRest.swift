import Parsing

public struct _Rest<Input: Collection>: Parser where Input.SubSequence == Input {
  public func parse(_ input: inout Input) throws -> Input {
    let output = input
    input.removeFirst(input.count)
    return output
  }
}

extension _Rest: ParserPrinter where Input: PrependableCollection {
  public func print(_ output: Input, into input: inout Input) throws {
    input.prepend(contentsOf: output)
  }
}

extension _Rest where Input == Substring.UTF8View {
  @_disfavoredOverload
  public init() { }
}
