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

public struct LazyVGrid<Content: HTML>: HTML {
  let columns: [MediaQuery?: [Int]]
  let content: Content
  let horizontalSpacing: Double?
  let verticalSpacing: Double?

  public init(
    columns: [MediaQuery: [Int]],
    // TODO: alignment: HorizontalAlignment = .center,
    horizontalSpacing: Double? = nil,
    verticalSpacing: Double? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.columns = columns
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
    self.content = content()
  }

  public init(
    columns: [Int],
    // TODO: alignment: HorizontalAlignment = .center,
    horizontalSpacing: Double? = nil,
    verticalSpacing: Double? = nil,
    @HTMLBuilder content: () -> Content
  ) {
    self.columns = [nil: columns]
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
    self.content = content()
  }

  public var body: some HTML {
    columns.reduce(
      tag("pf-vgrid") {
        content
      }
      .inlineStyle("", nil)  // TODO: Fix
    ) { html, columns in
      html
        .inlineStyle(
          "column-gap",
          horizontalSpacing == 0 ? "0" : "\(horizontalSpacing ?? .defaultSpacing)rem",
          media: columns.key
        )
        .inlineStyle("display", "grid", media: columns.key)
        .inlineStyle(
          "grid-template-columns",
          columns.value.map { "\($0)fr" }.joined(separator: " "),
          media: columns.key
        )
        .inlineStyle(
          "row-gap",
          verticalSpacing == 0 ? "0" : "\(verticalSpacing ?? .defaultSpacing)rem",
          media: columns.key
        )
    }
  }
}

extension Double {
  fileprivate static let defaultSpacing: Self = 1
}
