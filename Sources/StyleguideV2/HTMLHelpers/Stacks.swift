public struct HStack<Content: HTML>: HTML {
  let alignment: VerticalAlignment
  let spacing: Double?
  let content: Content

  public init(
    alignment: VerticalAlignment = .stretch,
    spacing: Double? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: some HTML {
    tag("pf-hstack") {
      content
    }
    .inlineStyle("align-items", alignment.rawValue)
    .inlineStyle("display", "flex")
    .inlineStyle("flex-direction", "row")
    .inlineStyle("column-gap", spacing == 0 ? "0" : "\(spacing ?? .defaultSpacing)rem")
  }
}

public struct VStack<Content: HTML>: HTML {
  let alignment: HorizontalAlignment
  let spacing: Double?
  let content: Content

  public init(
    alignment: HorizontalAlignment = .stretch,
    spacing: Double? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  public var body: some HTML {
    tag("pf-vstack") {
      content
    }
    .inlineStyle("align-items", alignment.rawValue)
    .inlineStyle("display", "flex")
    .inlineStyle("flex-direction", "column")
    .inlineStyle("row-gap", spacing == 0 ? "0" : "\(spacing ?? .defaultSpacing)rem")
  }
}

public struct HorizontalAlignment {
  public var rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  public static let center = Self(rawValue: "center")
  public static let leading = Self(rawValue: "start")
  public static let stretch = Self(rawValue: "stretch")
  public static let trailing = Self(rawValue: "end")
}

public struct VerticalAlignment: RawRepresentable {
  public var rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  public static let bottom = Self(rawValue: "end")
  public static let center = Self(rawValue: "center")
  public static let firstTextBaseline = Self(rawValue: "first baseline")
  public static let lastTextBaseline = Self(rawValue: "last baseline")
  public static let stretch = Self(rawValue: "stretch")
  public static let top = Self(rawValue: "start")
}

public struct Spacer: HTML {
  public init() {}
  public var body: some HTML {
    tag("pf-spacer").grow()
  }
}

extension HTML {
  public func grow(_ n: Int? = 1, _ media: MediaQuery? = nil) -> some HTML {
    inlineStyle("flex-grow", n.map { "\($0)" }, media: media)
  }

  public func shrink(_ n: Int? = 1, _ media: MediaQuery? = nil) -> some HTML {
    inlineStyle("flex-shrink", n.map { "\($0)" }, media: media)
  }
}

extension HTML {
  public func grid(
    columns: [Int],
    // TODO: alignment: Alignment = .center,
    horizontalSpacing: Double? = nil,
    verticalSpacing: Double? = nil,
    _ media: MediaQuery? = nil
  ) -> some HTML {
    tag("pf-grid") {
      self
    }
    .inlineStyle("display", "grid", media: media)
    .inlineStyle(
      "column-gap",
      horizontalSpacing == 0 ? "0" : "\(horizontalSpacing ?? .defaultSpacing)rem",
      media: media
    )
    .inlineStyle("grid-auto-rows", "1fr", media: media)
    .inlineStyle(
      "grid-template-columns",
      columns.map { "\($0)fr" }.joined(separator: " "),
      media: media)
    .inlineStyle(
      "row-gap",
      verticalSpacing == 0 ? "0" : "\(verticalSpacing ?? .defaultSpacing)rem",
      media: media
    )
  }
}

//public struct GridItem {
//  let fraction: Int
//
//  public static func fraction(_ fraction: Int) -> Self {
//    Self(fraction: fraction)
//  }
//}
//
//public struct LazyVGrid<Content: HTML>: HTML {
//  let columns: [GridItem]
//  let content: Content
//  let spacing: Double?
//
//  public init(
//    columns: [GridItem],
//    // TODO: alignment: HorizontalAlignment = .center,
//    spacing: Double? = nil,
//    @HTMLBuilder content: () -> Content
//  ) {
//    self.columns = columns
//    self.spacing = spacing
//    self.content = content()
//  }
//
//  public var body: some HTML {
//    tag("pf-vgrid") {
//      content
//    }
//    .inlineStyle("display", "grid")
//    .inlineStyle("gap", spacing == 0 ? "0" : "\(spacing ?? .defaultSpacing)rem")
//    .inlineStyle("grid-auto-rows", "1fr")
//    .inlineStyle("grid-template-columns", columns.map { "\($0.fraction)fr" }.joined(separator: " "))
//  }
//}

private extension Double {
  static let defaultSpacing: Self = 1
}
