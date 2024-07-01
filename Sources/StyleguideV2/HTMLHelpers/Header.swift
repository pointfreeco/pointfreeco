public struct Header<Content: HTML>: HTML {
  let size: Int
  @HTMLBuilder let content: Content
  public init(_ size: Int = 3, @HTMLBuilder content: () -> Content) {
    self.size = size
    self.content = content()
  }

  public var body: some HTML {
    tag("h\(size)") {
      content
    }
    .inlineStyle("margin", "0")
    .inlineStyle("margin-top", "\(marginTop)rem", pseudo: .not(.firstChild))
    .inlineStyle("margin-bottom", "\(marginBottom)rem", pseudo: .not(.lastChild))
    .inlineStyle("font-size", "\(fontSize)rem")
    .inlineStyle("font-weight", "700")
    .inlineStyle("line-height", "\(lineHeight)")
  }
  
  var fontSize: Double {
    switch size {
    case 1: 4
    case 2: 3
    case 3: 2
    case 4: 1.5
    case 5: 1
    default: 0.875
    }
  }
  var lineHeight: Double {
    switch size {
    case 1: 1.2
    case 2: 1.2
    case 3: 1.2
    case 4: 1.2
    case 5: 1.15
    default: 1.15
    }
  }
  var marginBottom: Double {
    switch size {
    case 1: 1
    case 2: 0.75
    case 3: 0.5
    case 4: 0.5
    case 5: 0.5
    default: 0.3
    }
  }
  var marginTop: Double {
    switch size {
    case 1: 2
    case 2: 1.75
    case 3: 1.5
    case 4: 1.5
    case 5: 0.5
    default: 0.5
    }
  }
}
