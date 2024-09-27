public protocol HTML {
  associatedtype Content: HTML
  @HTMLBuilder
  var body: Content { get }
  static func _render(_ html: Self, into printer: inout HTMLPrinter)
}

extension HTML {
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    Content._render(html.body, into: &printer)
  }
}

extension Never: HTML {
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {}
  public var body: Never { fatalError() }
}

public enum HTMLLocals {
  @TaskLocal public static var isCustomTagSupported = true
  @TaskLocal public static var isFlexSupported = true
}
