public struct HTMLRaw: HTML {
  let bytes: ContiguousArray<UInt8>
  public init(_ string: String) {
    self.init(string.utf8)
  }
  public init(_ bytes: some Sequence<UInt8>) {
    self.bytes = ContiguousArray(bytes)
  }
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    printer.bytes.append(contentsOf: html.bytes)
  }
  public var body: Never { fatalError() }
}
