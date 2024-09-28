//public struct Table<Content: HTML>: HTML {
//  let content: Content
//  public init(@HTMLBuilder content: () -> Content) {
//    self.content = content()
//  }
//
//  public var body: some HTML {
//    tag("table") {
//      content
//    }
//  }
//}
//
//public struct TableRow<Content: HTML>: HTML {
//  let content: Content
//  public init(@HTMLBuilder content: () -> Content) {
//    self.content = content()
//  }
//  public var body: some HTML {
//    tag("tr") {
//      content
//    }
//  }
//}
//
//public struct TableData<Content: HTML>: HTML {
//  let content: Content
//  public init(@HTMLBuilder content: () -> Content) {
//    self.content = content()
//  }
//  public var body: some HTML {
//    tag("td") {
//      content
//    }
//  }
//}
//
//extension HTML {
//  public func role(_ role: String) -> some HTML {
//    attribute("role", role)
//  }
//  public func border(_ width: Int) -> some HTML {
//    attribute("border", width.description)
//  }
//  public func cellspacing(_ cellspacing: Int) -> some HTML {
//    attribute("cellspacing", cellspacing.description)
//  }
//  public func cellpadding(_ cellpadding: Int) -> some HTML {
//    attribute("cellpadding", cellpadding.description)
//  }
//  public func align(_ alignment: String) -> some HTML {
//    attribute("align", alignment)
//  }
//  public func borderCollapse(_ collapse: String) -> some HTML {
//    inlineStyle("border-collapse", collapse)
//  }
//  public func borderSpacing(_ spacing: String) -> some HTML {
//    inlineStyle("border-spacing", spacing)
//  }
//}
