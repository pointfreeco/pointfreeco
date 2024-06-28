import Html
import FunctionalCss

public struct Grid<Content: HTML>: HTML {
  @HTMLBuilder let content: Content
  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some HTML {
    tag("pf-grid") {
      content
    }
    .inlineStyle("box-sizing", "border-box")
    .inlineStyle("display", "flex")
    .inlineStyle("flex-grow", "0")
    .inlineStyle("flex-shrink", "1")
    .inlineStyle("flex-basis", "auto")
    .inlineStyle("flex-direction", "row")
    .inlineStyle("flex-wrap", "wrap")
  }

  public enum Alignment: String {
    case baseline = "baseline"
    case center = "center"
    case end = "flex-end"
    case start = "flex-start"
    case stretch = "stretch"
  }
}

extension HTML {
  public func grid(alignment: Grid<Never>.Alignment, media: MediaQuery? = nil) -> some HTML {
    self
      .inlineStyle("align-items", alignment.rawValue)
  }
}

public struct GridColumn<Content: HTML>: HTML {
  @HTMLBuilder let content: Content
  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some HTML {
    tag("pf-column") {
      content
    }
    .inlineStyle("max-width", "100%")
    .inlineStyle("box-sizing", "border-box")
  }

  public enum Alignment: String {
    case center
    case end
    case start
    var justifyContent: String {
      switch self {
      case .center: "center"
      case .end: "flex-end"
      case .start: "flex-start"
      }
    }
    var textAlign: String {
      switch self {
      case .center: "center"
      case .end: "end"
      case .start: "start"
      }
    }
  }
}

extension HTML {
  public func column(
    count: Int,
    media: MediaQuery? = nil
  ) -> HTMLInlineStyle<Self> {
    self
      .inlineStyle("flex-basis", "\(Double(count) / 0.12)%", media: media?.rawValue)
      .inlineStyle("max-width", "\(Double(count) / 0.12)%", media: media?.rawValue)
  }
  
  public func column(
    alignment: GridColumn<Never>.Alignment,
    media: MediaQuery? = nil
  ) -> HTMLInlineStyle<Self> {
    self
      .inlineStyle("justify-content", alignment.justifyContent, media: media?.rawValue)
      .inlineStyle("text-align", alignment.textAlign, media: media?.rawValue)
  }

  public func inflexible() -> some HTML {
    self
      .inlineStyle("flex-grow", "0")
      .inlineStyle("flex-shrink", "0")
  }

  public func flexible() -> some HTML {
    self
      .inlineStyle("flex-grow", "1")
      .inlineStyle("flex-shrink", "1")
  }
}
