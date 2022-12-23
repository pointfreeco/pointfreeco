import Css
import Dependencies
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Stripe
import Styleguide

public func giftRedeemLanding(
  gift: Gift,
  subscriberState: SubscriberState,
  currentUser: User?,
  episodeStats: EpisodeStats
) -> Node {
  [
    landingHero(title: "Explore the wonderful world of&nbsp;functional programming in Swift."),
    mainContent(
      gift: gift,
      subscriberState: subscriberState,
      currentUser: currentUser,
      episodeStats: episodeStats
    ),
    whatToExpect,
    faq(faqs: .redeemFaqs),
    whatPeopleAreSaying,
    featuredTeams,
  ]
}

private func mainContent(
  gift: Gift,
  subscriberState: SubscriberState,
  currentUser: User?,
  episodeStats: EpisodeStats
) -> Node {
  [
    .gridRow(
      attributes: [
        .class([
          Class.padding([.mobile: [.leftRight: 2, .top: 3], .desktop: [.leftRight: 4, .top: 4]]),
          Class.grid.between(.desktop),
        ])
      ],
      .gridColumn(
        sizes: [.mobile: 12],
        attributes: [
          .class([
            Class.grid.center(.desktop),
            Class.padding([.desktop: [.bottom: 2]]),
          ])
        ],
        .h3(
          attributes: [
            .class([Class.pf.type.responsiveTitle4])
          ],
          "🎁 You’ve received a gift!"
        )
      )
    ),
    .ul(
      attributes: [
        .class([
          Class.margin([.mobile: [.all: 0]]),
          Class.grid.center(.desktop),
          Class.padding([
            .mobile: [.leftRight: 0, .top: 0, .bottom: 3],
            .desktop: [.leftRight: 2, .top: 0, .bottom: 4],
          ]),
          Class.type.list.styleNone,
          Class.flex.wrap,
          Class.flex.flex,
        ]),
        .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
      ],
      giftOption(
        gift: gift,
        subscriberState: subscriberState,
        currentUser: currentUser,
        episodeStats: episodeStats
      )
    ),
  ]
}

func giftOption(
  gift: Gift,
  subscriberState: SubscriberState,
  currentUser: User?,
  episodeStats: EpisodeStats
) -> ChildOf<Tag.Ul> {

  guard let plan = Gifts.Plan(monthCount: gift.monthsFree)
  else { return [] }
  let title: Node
  switch plan {
  case .threeMonths:
    title = .text("3 months free")
  case .sixMonths:
    title = .text("6 months free")
  case .year:
    title = .text("1 year free")
  }

  return .li(
    attributes: [
      .class([
        Class.grid.start(.desktop),
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 1]]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        giftOptionSelector,
      ])
    ],
    .div(
      attributes: [
        .class([
          Class.pf.colors.bg.gray900,
          Class.flex.column,
          Class.padding([.mobile: [.all: 2]]),
          Class.size.width100pct,
          Class.flex.flex,
        ])
      ],
      .h4(
        attributes: [.class([Class.pf.type.responsiveTitle4])],
        title
      ),
      .ul(
        attributes: [
          .class([
            Class.type.list.styleNone,
            Class.padding([.mobile: [.all: 0]]),
            Class.pf.colors.fg.gray400,
            Class.pf.type.body.regular,
            Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
            Class.pf.colors.fg.gray400,
          ]),
          .style(flex(grow: 1, shrink: 0, basis: .auto)),
        ],
        .fragment(
          plan.features(episodeStats: episodeStats)
            .filter { !$0.isHighlighted }
            .map { feature in
              .li(
                attributes: [.class([Class.padding([.mobile: [.top: 1]])])],
                .div(
                  attributes: [
                    .class([pricingPlanFeatureClass])
                  ],
                  .raw(unsafeMark(from: feature.name))
                )
              )
            }
        )
      ),
      existingSubscriberNotice(subscriberState: subscriberState),
      loginOrRedeem(
        gift: gift,
        currentUser: currentUser
      )
    )
  )
}

private func existingSubscriberNotice(
  subscriberState: SubscriberState
) -> Node {
  if subscriberState.isActive {
    return .div(
      attributes: [
        .class([
          Class.margin([.mobile: [.top: 2], .desktop: [.top: 2]]),
          Class.padding([.mobile: [.all: 2]]),
        ]),
        .style(
          key("background", "#ffd")
        ),
      ],
      "Since you are already a subscriber, the gift amount will be applied to your future invoices."
    )
  } else {
    return []
  }
}

private func loginOrRedeem(
  gift: Gift,
  currentUser: User?
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  if currentUser == nil {
    return .gitHubLink(
      text: "Log in to redeem",
      type: .black,
      href: siteRouter.loginPath(redirect: .gifts(.redeem(gift.id))),
      size: .regular,
      extraClasses:
        Class.display.block
        | Class.size.width100pct
        | Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]])
    )
  } else {
    return .form(
      attributes: [
        .method(.post),
        .action(siteRouter.path(for: .gifts(.redeem(gift.id, .confirm)))),
      ],
      .input(
        attributes: [
          .type(.submit),
          .value("Redeem"),
          .class([
            Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
            Class.pf.components.button(color: .black, size: .regular, style: .normal),
            Class.size.width100pct,
          ]),
        ]
      )
    )
  }
}

extension Array where Element == Faq {
  fileprivate static let redeemFaqs = [
    Faq(
      question: "Do I need to give a credit card to redeem the gift?",
      answer: """
        Nope. No credit card is required, and when the gift time is almost up we will send you an email to see if you want to continue your subscription.
        """),
    .existingSubscriberRedeemGift,
    .combinedWithStudentDiscountsEtc,
  ]
}
