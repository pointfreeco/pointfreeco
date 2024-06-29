public struct HomeModule<Title: HTML, Content: HTML>: HTML {
  let title: Title?
  var seeAllURL: String?
  var theme: PageModuleTheme
  let content: Content

  public init(
    seeAllURL: String? = nil,
    theme: PageModuleTheme,
    @HTMLBuilder content: () -> Content,
    @HTMLBuilder title: () -> Title
  ) {
    self.title = title()
    self.seeAllURL = seeAllURL
    self.theme = theme
    self.content = content()
  }

  public init(
    seeAllURL: String? = nil,
    theme: PageModuleTheme,
    @HTMLBuilder content: () -> Content
  ) where Title == Never {
    self.title = nil
    self.seeAllURL = seeAllURL
    self.theme = theme
    self.content = content()
  }

  public var body: some HTML {
    div {
      Grid {
        HTMLGroup {
          if let title {
            GridColumn {
              title
                .color(theme.color)
            }
            .column(count: seeAllURL == nil ? 12 : 10)
            .column(alignment: seeAllURL == nil ? .center : .start)
            .inlineStyle(
              "padding-bottom",
              seeAllURL == nil
              ? "\(theme.titleMarginBottom)rem"
              : "\(theme.titleMarginBottom/2)rem"
            )
          }

          if let seeAllURL {
            GridColumn {
              Link("See all →", href: seeAllURL)
                .linkColor(.purple)
            }
            .column(count: 2)
            .column(alignment: .end )
          }
        }

        content
      }
      .grid(alignment: .baseline)
      .inlineStyle("max-width", "1280px")
      .inlineStyle("margin", "0 auto")
      .inlineStyle(
        "padding",
        "\(theme.topMargin)rem \(theme.leftRightMargin)rem \(theme.bottomMargin)rem"
      )
      .inlineStyle(
        "padding",
        "\(theme.topMargin)rem \(theme.leftRightMarginDesktop)rem \(theme.bottomMargin)rem",
        media: .desktop
      )
      .backgroundColor(theme.contentBackgroundColor)
    }
    .backgroundColor(theme.backgroundColor)
  }
}

public struct PageModuleTheme {
  var backgroundColor: PointFreeColor?
  var contentBackgroundColor: PointFreeColor?
  var color: PointFreeColor
  let topMargin: Double
  let bottomMargin: Double
  let leftRightMargin: Double
  let leftRightMarginDesktop: Double
  let titleMarginBottom: Double

  public init(
    backgroundColor: PointFreeColor? = nil,
    contentBackgroundColor: PointFreeColor? = nil,
    color: PointFreeColor,
    topMargin: Double,
    bottomMargin: Double,
    leftRightMargin: Double,
    leftRightMarginDesktop: Double,
    titleMarginBottom: Double
  ) {
    self.backgroundColor = backgroundColor
    self.contentBackgroundColor = contentBackgroundColor
    self.color = color
    self.topMargin = topMargin
    self.bottomMargin = bottomMargin
    self.leftRightMargin = leftRightMargin
    self.leftRightMarginDesktop = leftRightMarginDesktop
    self.titleMarginBottom = titleMarginBottom
  }
}
