public struct AnyHTML: HTML {
  let base: any HTML
  init(_ base: any HTML) {
    self.base = base
  }
  public static func _render(_ html: AnyHTML, into printer: inout HTMLPrinter) {
    func render<T: HTML>(_ html: T) {
      T._render(html, into: &printer)
    }
    render(html.base)
  }
  public var body: Never { fatalError() }
}
