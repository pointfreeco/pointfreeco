import Html
import FunctionalCss

public struct GridRow<Content: NodeView>: NodeView {
  let alignment: Alignment
  @NodeBuilder let content: Content
  public init(alignment: Alignment, @NodeBuilder content: () -> Content) {
    self.alignment = alignment
    self.content = content()
  }

  public var body: Node {
    div {
      content
    }
    .class([Class.grid.row, .class(alignment.rawValue)])
  }

  public enum Alignment: String {
    case start = "items-start"
    case end = "items-end"
    case center = "items-center"
    case baseline = "items-baseline"
    case stretch = "items-stretch"
  }
}
public struct GridColumn<Content: NodeView>: NodeView {
  var sizes: [Breakpoint: Int] = [:]
  @NodeBuilder let content: Content
  public init(@NodeBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: Node {
    div {
      content
    }
    .class([Class.grid.col(.mobile, nil)])
    .class(
      [Class.grid.col(.mobile, nil)] + sizes
        .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        .map(Class.grid.col(_:_:))
    )
  }
  
  public func columns(_ count: Int, breakpoint: Breakpoint) -> Self {
    var copy = self
    copy.sizes[breakpoint] = count
    return copy
  }
}
