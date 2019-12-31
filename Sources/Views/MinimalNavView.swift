import Css
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Styleguide

public enum NavStyle {
  case minimal(MinimalStyle)
  case mountains(MountainsStyle)

  public enum MinimalStyle {
    case black
    case dark
    case light
  }

  public enum MountainsStyle {
    case blog
    case main

    public var heroTagline: String {
      switch self {
      case .blog: return "A blog exploring functional programming and Swift."
      case .main: return "A video series exploring functional programming and Swift."
      }
    }

    public var heroLogoSvgBase64: String {
      switch self {
      case .blog: return pointFreePointersLogoSvgBase64
      case .main: return pointFreeHeroSvgBase64
      }
    }
  }
}

public func minimalNavView(
  style: NavStyle.MinimalStyle,
  currentUser: User?,
  subscriberState: SubscriberState,
  currentRoute: Route?
) -> Node {
  return .gridRow(
    attributes: [.class([newNavBarClass(for: style)])],
    .gridColumn(
      sizes: [:],
      .div(
        attributes: [.class([Class.hide(.desktop)])],
        .a(
          attributes: [.href(path(to: .home))],
          .img(
            base64: pointFreeDiamondLogoSvgBase64(fill: fillColor(for: style)),
            type: .image(.svg),
            alt: "",
            attributes: [.class([Class.hide(.desktop)])]
          )
        )
      )
    ),
    .gridColumn(
      sizes: [:],
      .div(
        attributes: [.class([Class.grid.center(.mobile)])],
        .div(
          attributes: [.class([Class.hide(.mobile)])],
          .a(
            attributes: [.href(path(to: .home))],
            .img(
              base64: pointFreeTextLogoSvgBase64(color: fillColor(for: style)),
              type: .image(.svg),
              alt: "",
              attributes: [.class([Class.hide(.mobile)])]
            )
          )
        )
      )
    ),
    .gridColumn(
      sizes: [:],
      currentUser
        .map { loggedInNavItemsView(style: style, currentUser: $0, subscriberState: subscriberState) }
        ?? loggedOutNavItemsView(style: style, currentRoute: currentRoute)
    )
  )
}

private func loggedInNavItemsView(
  style: NavStyle.MinimalStyle,
  currentUser: User,
  subscriberState: SubscriberState
) -> Node {
  return .ul(
    attributes: [.class([navListClass])],
    .li(
      attributes: [.class([navListItemClass])],
      blogLinkView(style: style)
    ),
    subscriberState.isNonSubscriber
      ? .li(attributes: [.class([navListItemClass])], subscribeLinkView(style: style))
      : [],
    .li(attributes: [.class([navListItemClass])], accountLinkView(style: style))
  )
}

private func loggedOutNavItemsView(style: NavStyle.MinimalStyle, currentRoute: Route?) -> Node {
  return .ul(
    attributes: [.class([navListClass])],
    .li(attributes: [.class([navListItemClass])], blogLinkView(style: style)),
    .li(attributes: [.class([navListItemClass])], subscribeLinkView(style: style)),
    .li(attributes: [.class([navListItemClass])], logInLinkView(style: style, currentRoute: currentRoute))
  )
}

private func blogLinkView(style: NavStyle.MinimalStyle) -> Node {
  return .a(attributes: [.href(path(to: .blog(.index))), .class([navLinkClass(for: style)])], "Blog")
}

private func subscribeLinkView(style: NavStyle.MinimalStyle) -> Node {
  return .a(attributes: [.href(path(to: .pricingLanding)), .class([navLinkClass(for: style)])], "Subscribe")
}

private func accountLinkView(style: NavStyle.MinimalStyle) -> Node {
  return .a(attributes: [.href(path(to: .account(.index))), .class([navLinkClass(for: style)])], "Account")
}

private func logInLinkView(style: NavStyle.MinimalStyle, currentRoute: Route?) -> Node {
  return .gitHubLink(
    text: "Log in",
    type: gitHubLinkType(for: style),
    href: path(to: .login(redirect: currentRoute.map(url(to:))))
  )
}

private func gitHubLinkType(for style: NavStyle.MinimalStyle) -> GitHubLinkType {
  switch style {
  case .black:
    return .white
  case .dark:
    return .white
  case .light:
    return .black
  }
}

private func navLinkClass(for style: NavStyle.MinimalStyle) -> CssSelector {
  switch style {
  case .black:
    return Class.pf.colors.link.gray650
  case .dark:
    return Class.pf.colors.link.green
  case .light:
    return Class.pf.colors.link.black
  }
}

private let navListItemClass =
  Class.padding([.mobile: [.left: 3]])
    | Class.display.inline

private let navListClass =
  Class.type.list.reset
    | Class.grid.end(.mobile)

private func newNavBarClass(for style: NavStyle.MinimalStyle) -> CssSelector {
  let colorClass: CssSelector
  switch style {
  case .black:
    colorClass = Class.pf.colors.bg.black
  case .dark:
    colorClass = Class.pf.colors.bg.purple150
  case .light:
    colorClass = Class.pf.colors.bg.blue900
  }

  return colorClass
    | Class.padding([.mobile: [.leftRight: 2, .topBottom: 2], .desktop: [.topBottom: 4]])
    | Class.grid.middle(.mobile)
    | Class.grid.between(.mobile)
}

private func fillColor(for minimalStyle: NavStyle.MinimalStyle) -> String {
  switch minimalStyle {
  case .black:
    return "#ffffff"
  case .dark:
    return "#ffffff"
  case .light:
    return "#121212"
  }
}
