import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Prelude
import Styleguide

public func pageLayoutV2(
  view: Node,
  layoutData: SimplePageLayoutData<Void>,
  metadata: Metadata<Void>,
  cssConfig: Css.Config,
  emergencyMode: Bool
) -> Node {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.date.now) var now
  @Dependency(\.siteRouter) var siteRouter

  return [
    .doctype,
    .html(
      attributes: [.lang(.en)],
      .head(
        .meta(attributes: [.charset(.utf8)]),
        .title(layoutData.title),
        .style(safe: renderedNormalizeCss),
        .style(styleguide, config: cssConfig),
        .style(markdownBlockStyles, config: cssConfig),
        .style(layoutData.extraStyles, config: cssConfig),
        .style(
          safe: """
            @keyframes Pulse {
              from { opacity: 1; }
              50% { opacity: 0; }
              to { opacity: 1; }
            }
            """),
        .meta(viewport: .width(.deviceWidth), .initialScale(1)),
        .link(
          attributes: [
            .href(siteRouter.url(for: .feed(.episodes))),
            .rel(.alternate),
            .title("Point-Free Episodes"),
            .type(.application(.init(rawValue: "atom+xml"))),
          ]
        ),
        .link(
          attributes: [
            .href(siteRouter.url(for: .blog(.feed))),
            .rel(.alternate),
            .title("Point-Free Blog"),
            // TODO: add .atom to Html
            .type(.application(.init(rawValue: "atom+xml"))),
          ]
        ),
        (layoutData.usePrismJs ? prismJsHead : []),
        favicons,
        layoutData.extraHead
      ),
      .body(
        ghosterBanner(isGhosting: layoutData.isGhosting),
        pastDueBanner,
        (layoutData.flash.map(flashView) ?? []),
        announcementBanner(.wwdc24),
        liveStreamBanner,
        emergencyModeBanner(emergencyMode, layoutData),
        navViewV2(),
        view,
        layoutData.style.isMinimal
          ? []
          : footerView(
            user: currentUser,
            year: Calendar(identifier: .gregorian).component(.year, from: now)
          )
      )
    ),
  ]
}

public func navViewV2() -> Node {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.currentRoute) var siteRoute
  @Dependency(\.siteRouter) var siteRouter

  return .div(
    attributes: [.class([newNavBarClass(for: .black)])],
    .div(
      attributes: [
        .style(.concat(maxWidth(.px(1080)), margin(topBottom: nil, leftRight: .auto)))
      ],
      .gridRow(
        attributes: [.class([Class.flex.items.center])],
        .gridColumn(
          sizes: [.mobile: 2],
          .a(
            attributes: [.href(siteRouter.path(for: .home))],
            .img(
              base64: pointFreeTextDiamondLogoSvgBase64(fill: fillColor(for: .black)),
              type: .image(.svg),
              alt: "Point-Free"
            )
          )
        ),
        .gridColumn(
          sizes: [.desktop: 8],
          attributes: [
            .class([
              Class.flex.items.center,
              Class.grid.center(.mobile),
              Class.hide(.mobile),
            ])
          ],
          centeredNavItemsView()
        ),
        .gridColumn(
          sizes: [.desktop: 2],
          attributes: [
            .class([
              Class.flex.items.end,
              Class.hide(.mobile)
            ])
          ],
          trailingNavItemsView()
        ),
        .gridColumn(
          sizes: [.mobile: 10],
          attributes: [
            .class([
              Class.flex.items.end,
              Class.hide(.desktop)
            ])
          ],
          mobileMenuView()
        )
      )
    )
  )
}

func mobileMenuView() -> Node {
  func menuBar(index: Int) -> Node {
    .div(
      attributes: [
        //menuBarClasses
        .class([
          Class.display.block,
          Class.pf.colors.bg.white,
          Class.position.absolute,
          .class("menu-bar-\(index)")
        ]),
        .style(
          //    transition: transform 400ms cubic-bezier(0.23, 1, 0.32, 1);
          height(.px(4))
          <> width(.px(30))
          <> borderRadius(all: .px(2))
          <> content(Content.none)
          <> margin(top: .px(Double(index) * 8))
        )
      ]
    )
  }

  return [
    .div(
      attributes: [
        .class([
          Class.grid.end(.mobile),
        ])
      ],
      .label(
        attributes: [
          .class([			
            .class("menu-checkbox-container"),
            Class.flex.flex,
            Class.flex.column,
            Class.cursor.pointer,
          ]),
          .style(
            height(.pct(100))
            <> width(.px(30))
            <> justify(content: .center)
            <> align(items: .center)
          ),
          .for("menu-checkbox")
        ],
        menuBar(index: -1),
        menuBar(index: 0),
        menuBar(index: 1)
      ),
      .input(
        attributes: [
          .id("menu-checkbox"),
          .type(.checkbox),
          .class([Class.hide]),
        ]
      )
    )
  ]
}

func trailingNavItemsView() -> Node {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  let classes = [
    Class.type.list.reset,
    Class.grid.end(.mobile),
    Class.pf.type.body.small
  ]

  if currentUser != nil {
    return .ul(
      attributes: [
        .class(classes)
      ],
      .li(
        attributes: [.class([trailingNavListItemClasses])],
        .a(
          attributes: [
            .class([Class.pf.components.button(color: .purple, size: .small)]),
            .href(siteRouter.path(for: .account(.index))),
          ],
          "Account"
        )
      )
    )
  } else {
    return .ul(
      attributes: [
        .class(classes)
      ],
      .li(
        attributes: [.class([trailingNavListItemClasses])],
        .a(
          attributes: [
            .class([Class.pf.components.button(color: .purple, size: .small, style: .outline)]),
            .href(siteRouter.path(for: .account(.index))),
          ],
          "Login"
        )
      ),
      .li(
        attributes: [.class([trailingNavListItemClasses])],
        .a(
          attributes: [
            .class([Class.pf.components.button(color: .purple, size: .small)]),
            .href(siteRouter.path(for: .account(.index))),
          ],
          "Sign up"
        )
      )
    )
  }
}

func centeredNavItemsView() -> Node {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  return .ul(
    attributes: [
      .class([
        Class.type.list.reset,
        Class.grid.middle(.mobile),
        Class.pf.type.body.small,
      ])
    ],
    currentUser != nil
      ? .li(attributes: [.class([centerListItemClasses])], episodesLinkView())
      : [],
    .li(
      attributes: [.class([centerListItemClasses])],
      collectionsLinkView()
    ),
    subscriberState.isNonSubscriber
      ? .li(attributes: [.class([centerListItemClasses])], subscribeLinkView())
      : [],
    .li(
      attributes: [.class([centerListItemClasses])],
      blogLinkView()
    ),
    .li(attributes: [.class([centerListItemClasses])], giftLinkView())
  )
}

private let centerListItemClasses =
  Class.padding([.mobile: [.left: 3]])
  | Class.display.inline

private let trailingNavListItemClasses =
  Class.padding([.mobile: [.left: 2]])
  | Class.display.inline

private func collectionsLinkView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [
      .class([Class.pf.colors.link.gray650]),
      .href(siteRouter.path(for: .collections())),
    ], "Collections"
  )
}

private func blogLinkView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [.href(siteRouter.path(for: .blog())), .class([Class.pf.colors.link.gray650])],
    "Blog")
}

private func episodesLinkView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [.href(siteRouter.path(for: .homeV2)), .class([Class.pf.colors.link.gray650])],
    "Episodes"
  )
}

private func subscribeLinkView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [
      .href(siteRouter.path(for: .pricingLanding)), .class([Class.pf.colors.link.gray650]),
    ],
    "Pricing")
}

private func giftLinkView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [.href(siteRouter.path(for: .gifts())), .class([Class.pf.colors.link.gray650])],
    "Gifts"
  )
}

private func accountLinkView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .a(
    attributes: [.href(siteRouter.path(for: .account())), .class([Class.pf.colors.link.gray650])],
    "Account")
}

private func logInLinkView() -> Node {
  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.siteRouter) var siteRouter

  return .gitHubLink(
    text: "Log in",
    type: gitHubLinkType(for: .black),
    href: siteRouter.loginPath(redirect: currentRoute),
    size: .small
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
