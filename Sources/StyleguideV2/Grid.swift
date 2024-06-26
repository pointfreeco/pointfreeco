import Html
import FunctionalCss

public struct GridRowV2<Content: HTML>: HTML {
  let alignment: Alignment
  @HTMLBuilder let content: Content
  public init(alignment: Alignment, @HTMLBuilder content: () -> Content) {
    self.alignment = alignment
    self.content = content()
  }

  public var body: some HTML {
    div {
      content
    }
    .inlineStyle("align-items", alignment.rawValue)
    .inlineStyle("box-sizing", "border-box")
    .inlineStyle("display", "flex")
    .inlineStyle("flex-grow", "0")
    .inlineStyle("flex-shrink", "1")
    .inlineStyle("flex-basis", "auto")
    .inlineStyle("flex-direction", "wrap")
  }

  public enum Alignment: String {
    case baseline = "baseline"
    case center = "center"
    case end = "flex-end"
    case start = "flex-start"
    case stretch = "stretch"
  }
}

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

public struct GridColumnV2<Content: HTML>: HTML {
  var mobile: Int
  var desktop: Int?
  @HTMLBuilder let content: Content
  public init(
    _ mobile: Int,
    @HTMLBuilder content: () -> Content
  ) {
    self.init(mobile: mobile, desktop: nil, content: content)
  }
  public init(
    mobile: Int,
    desktop: Int?,
    @HTMLBuilder content: () -> Content
  ) {
    self.mobile = mobile
    self.desktop = desktop ?? mobile
    self.content = content()
  }

  public var body: some HTML {
    div {
      content
    }
    .inlineStyle("flex-grow", "1")
    .inlineStyle("flex-grow", "1", media: MediaQuery.desktop.rawValue)
    .inlineStyle("flex-basis", "0")
    .inlineStyle("flex-shrink", "0")
    .inlineStyle("max-width", "100%")
    .inlineStyle("box-sizing", "border-box")
    .inlineStyle("flex-basis", "\(Double(mobile) / 0.12)%")
    .inlineStyle("max-width", "\(Double(mobile) / 0.12)%")
    .inlineStyle("flex-basis", desktop.map { "\(Double($0) / 0.12)%" }, media: MediaQuery.desktop.rawValue)
    .inlineStyle("max-width", desktop.map { "\(Double($0) / 0.12)%" }, media: MediaQuery.desktop.rawValue)
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
