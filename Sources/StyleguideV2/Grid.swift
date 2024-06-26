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
  var sizes: [MediaQuery?: Int] = [:]
  @HTMLBuilder let content: Content
  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some HTML {
    div {
      content
    }

    // .col-m
    .inlineStyle("flex-grow", "1")
    .inlineStyle("flex-basis", "0")
    .inlineStyle("max-width", "100%")
    .inlineStyle("box-sizing", "border-box")
    
//    .col-m-1 {
//      flex-basis: 8.333333333333334%;
//      max-width:8.333333333333334%
//    }

//    Class.grid.col(breakpoint, idx)
//    % (flex(basis: .pct(100 * Double(idx) / 12))
//       <> maxWidth(.pct(100 * Double(idx) / 12)))

//    .class(
//      [Class.grid.col(.mobile, nil)] + sizes
//        .sorted(by: { $0.key.rawValue < $1.key.rawValue })
//        .map(Class.grid.col(_:_:))
//    )
  }

  public func columns(_ count: Int, media: MediaQuery?) -> Self {
    var copy = self
    copy.sizes[media] = count
    return copy
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
