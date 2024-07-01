public struct HTMLEmpty: HTML {
  public init() {}
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {}
  public var body: Never { fatalError() }
}
