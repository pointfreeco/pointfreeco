import Css
import Dependencies
import EmailAddress
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tagged
import TaggedMoney

public func subscriptionConfirmation(
  lane: Pricing.Lane,
  subscribeData: SubscribeConfirmationData,
  coupon: Stripe.Coupon?,
  currentUser: User?,
  subscriberState: SubscriberState = .nonSubscriber,
  referrer: User?,
  episodeStats: EpisodeStats,
  stripeJs: String,
  stripePublishableKey: Stripe.Client.PublishableKey
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return .form(
    attributes: [
      .action(siteRouter.path(for: .subscribe())),
      .id("subscribe-form"),
      .method(.post),
      .onsubmit(safe: "event.preventDefault()"),
      .style(maxWidth(.px(900)) <> margin(leftRight: .auto)),
    ],
    header(
      currentUser: currentUser,
      subscriberState: subscriberState,
      referrer: referrer,
      episodeStats: episodeStats,
      lane: lane,
      coupon: coupon,
      useRegionalDiscount: subscribeData.useRegionalDiscount
    ),
    currentUser.map { teamMembers(lane: lane, currentUser: $0, subscribeData: subscribeData) }
      ?? [],
    billingPeriod(coupon: coupon, lane: lane, subscribeData: subscribeData),
    currentUser != nil
      ? payment(
        lane: lane,
        coupon: coupon,
        stripeJs: stripeJs,
        stripePublishableKey: stripePublishableKey,
        referrer: referrer,
        useRegionalDiscount: subscribeData.useRegionalDiscount
      )
      : [],
    total(
      isLoggedIn: currentUser != nil,
      lane: lane,
      coupon: coupon,
      referrer: referrer,
      useRegionalDiscount: subscribeData.useRegionalDiscount
    )
  )
}

private func additionalDiscountInfo(
  referrer: User?,
  coupon: Coupon?,
  useRegionalDiscount: Bool
) -> Node {

  func additionalReferrerInfo(referrer: User) -> Node {
    [
      """
      You are using the referral code \(.strong(.text(referrer.referralCode.rawValue))) to
      receive one month free and to give \(.strong(.text(referrer.name ?? "your referrer"))) a
      free month.
      """,
      .input(attributes: [
        .name(SubscribeData.CodingKeys.referralCode.rawValue),
        .type(.hidden),
        .value(referrer.referralCode.rawValue),
      ]),
    ]
  }

  func additionalCouponInfo(coupon: Coupon) -> Node {
    [
      coupon.name.map { .raw(" You are using the coupon <strong>\($0)</strong>") }
        ?? " You are using a coupon",
      ", which gives you \(coupon.formattedDescription).",
      .input(
        attributes: [
          .class([Class.display.none]),
          .disabled(true),
          .name(SubscribeData.CodingKeys.coupon.rawValue),
          .placeholder("Coupon Code"),
          .type(.hidden),
          .value(coupon.id.rawValue),
        ]
      ),
    ]
  }

  let additionalRegionalDiscountInfo: Node = [
    """
    To make up for currency discrepencies between the United States and other countries, we offer
    a regional discount. If your credit card's issuing country is one of the countries listed
    below we will apply a \(.strong("50% discount")) to every billing cycle.
    """,
    .details(
      .summary(attributes: [.class([Class.cursor.pointer])], "Expand country list"),
      .div(
        attributes: [
          .class([
            Class.padding([.mobile: [.topBottom: 1, .leftRight: 2]])
          ])
        ],
        .ul(
          .fragment(
            DiscountCountry.all.map { country in
              .li(.text(country.name))
            }
          )
        )
      )
    ),
    .input(
      attributes: [
        .class([Class.display.none]),
        .disabled(true),
        .name(SubscribeData.CodingKeys.useRegionalDiscount.rawValue),
        .placeholder("Coupon Code"),
        .type(.hidden),
        .value("\(useRegionalDiscount)"),
      ]
    ),
  ]

  if let referrer = referrer, useRegionalDiscount {
    return additionalDiscountInfo(
      title: "Referral credit and regional discount",
      message: [
        .ul(
          .li(.p(additionalReferrerInfo(referrer: referrer))),
          .li(.p(additionalRegionalDiscountInfo))
        )
      ]
    )
  }

  if let referrer = referrer {
    return additionalDiscountInfo(
      title: "Referral credit",
      message: .p(additionalReferrerInfo(referrer: referrer))
    )
  }

  if let coupon = coupon {
    return additionalDiscountInfo(
      title: "Coupon applied",
      message: .p(additionalCouponInfo(coupon: coupon))
    )
  }

  if useRegionalDiscount {
    return additionalDiscountInfo(
      title: "Regional discount",
      message: .p(additionalRegionalDiscountInfo)
    )
  }

  return []
}

private func additionalDiscountInfo(
  title: String,
  message: Node
) -> Node {
  .gridColumn(
    sizes: [.mobile: 12],
    attributes: [.style(margin(leftRight: .auto))],
    .div(
      attributes: [
        .style(backgroundColor(.rgb(0xff, 0xff, 0xdd))),
        .class([Class.margin([.mobile: [.top: 2]]), Class.padding([.mobile: [.all: 2]])]),
      ],
      .h4(
        attributes: [
          .class([Class.pf.type.responsiveTitle6, Class.padding([.mobile: [.bottom: 1]])])
        ],
        .text(title)
      ),
      message
    )
  )
}

private func header(
  currentUser: User? = nil,
  subscriberState: SubscriberState = .nonSubscriber,
  referrer: User?,
  episodeStats: EpisodeStats,
  lane: Pricing.Lane,
  coupon: Coupon?,
  useRegionalDiscount: Bool
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let header: Node = [
    .gridColumn(
      sizes: [:],
      attributes: [.class([Class.grid.start(.mobile)])],
      "You selected the \(.strong(lane == .personal ? "Personal" : "Team")) plan"
    ),
    .gridColumn(
      sizes: [:],
      attributes: [.class([Class.grid.end(.mobile)])],
      .a(
        attributes: [
          .class([
            Class.pf.colors.link.gray650,
            Class.pf.type.underlineLink,
          ]),
          .href(siteRouter.url(for: .pricingLanding)),
        ],
        "Change plan"
      )
    ),
    planFeatures(
      currentUser: currentUser,
      episodeStats: episodeStats,
      lane: lane
    ),
    additionalDiscountInfo(
      referrer: referrer, coupon: coupon, useRegionalDiscount: useRegionalDiscount),
  ]

  return [
    .input(attributes: [
      .name("pricing[lane]"),
      .type(.hidden),
      .value(lane.rawValue),
    ]),
    .gridRow(
      attributes: [.class([moduleRowClass])],
      .gridColumn(
        sizes: [.mobile: 12],
        .h1(attributes: [.class([Class.pf.type.responsiveTitle2])], "Subscribe")
      ),
      header
    ),
  ]
}

func planFeatures(
  currentUser: User?,
  episodeStats: EpisodeStats,
  lane: Pricing.Lane,
  showDiscountOptions: Bool = true
) -> Node {
  .gridColumn(
    sizes: [.mobile: 12],
    .ul(
      attributes: [
        .class([
          Class.padding([.mobile: [.all: 0]]),
          Class.margin([.mobile: [.left: 3]]),
          Class.pf.colors.fg.gray400,
          Class.pf.type.body.regular,
          Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
          Class.pf.colors.fg.gray400,
        ]),
        .style(flex(grow: 1, shrink: 0, basis: .auto)),
      ],
      .fragment(
        PricingPlan.personal(
          allEpisodeCount: episodeStats.allEpisodeCount,
          episodeHourCount: episodeStats.episodeHourCount,
          showDiscountOptions: showDiscountOptions
        )
        .features
        .map { feature in
          .li(
            attributes: [.class([Class.padding([.mobile: [.top: 1]])])],
            .div(
              attributes: [.class([pricingPlanFeatureClass])],
              .raw(unsafeMark(from: feature))
            )
          )
        }
      )
    )
  )
}

private func teamMembers(
  lane: Pricing.Lane,
  currentUser: User,
  subscribeData: SubscribeConfirmationData
) -> Node {

  guard lane == .team else {
    return .input(attributes: [
      .name(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue),
      .type(.hidden),
      .value("true"),
    ])
  }

  return .gridRow(
    attributes: [.class([moduleRowClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([moduleTitleColumnClass])],
      .h1(attributes: [.class([moduleTitleClass])], "Team members")
    ),
    teamOwner(currentUser: currentUser, subscribeData: subscribeData),
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.id("team-members")],
      .fragment(subscribeData.teammates.map { teamMemberTemplate($0, withRemoveButton: false) })
    ),
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([Class.padding([.mobile: [.top: 3]])])],
      .div(
        .template(
          attributes: [.id("team-member-template")],
          teamMemberTemplate("", withRemoveButton: true)
        ),
        .template(
          attributes: [.id("team-member-template-without-remove")],
          teamMemberTemplate("", withRemoveButton: false)
        ),
        .a(
          attributes: [
            .id("add-team-member-button"),
            .class([
              Class.type.medium,
              Class.cursor.pointer,
              Class.type.nowrap,
              Class.pf.colors.link.black,
              Class.pf.colors.fg.black,
              Class.pf.colors.bg.white,
              Class.h5,
              Class.padding([.mobile: [.leftRight: 2, .topBottom: 2]]),
              Class.border.all,
              Class.pf.colors.border.gray850,
            ]),
            .onclick(
              safe: """
                var teamMember = document.getElementById("team-member-template").content.cloneNode(true)
                document.getElementById("team-members").appendChild(teamMember)
                updateSeats()
                """),
          ],
          "Add team member"
        )
      )
    ),
    .p(
      attributes: [
        .class([
          Class.pf.type.body.small,
          Class.pf.colors.fg.gray400,
          Class.padding([.mobile: [.top: 3]]),
        ])
      ],
      """
      You must have at least two seats for your team subscription. You can add additional team members at any time
      from your account page.
      """
    )
  )
}

private func teamOwner(currentUser: User, subscribeData: SubscribeConfirmationData) -> Node {
  guard subscribeData.isOwnerTakingSeat else {
    return .input(attributes: [
      .name(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue),
      .type(.hidden),
      .value("false"),
    ])
  }

  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .id("team-owner"),
      .class([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.top: 1]]),
      ]),
      .style(lineHeight(0)),
    ],
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile),
        ])
      ],
      .input(
        attributes: [
          .name(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue),
          .type(.hidden),
          .value("true"),
        ]
      ),
      .img(
        src: currentUser.gitHubAvatarUrl.absoluteString,
        alt: "",
        attributes: [
          .class([
            Class.pf.colors.bg.green,
            Class.border.circle,
            Class.margin([.mobile: [.right: 1]]),
          ]),
          .style(width(.px(24)) <> height(.px(24))),
        ]
      ),
      .span(
        attributes: [.class([Class.size.width100pct])],
        .text(currentUser.displayName)
      ),
      .a(
        attributes: [
          .id("remove-yourself-button"),
          .class([
            Class.cursor.pointer,
            Class.pf.colors.fg.red,
            Class.pf.colors.link.red,
            Class.type.light,
            Class.pf.type.body.small,
            Class.pf.type.underlineLink,
          ]),
          .onclick(
            safe: """
              var ownerRow = this.parentNode.parentNode
              ownerRow.parentNode.removeChild(ownerRow)

              var teamMember = document.getElementById("team-member-template-without-remove").content.cloneNode(true)
              var teamMembersContainer = document.getElementById("team-members")
              teamMembersContainer.insertBefore(teamMember, teamMembersContainer.firstChild)

              updateSeats()
              """
          ),
        ],
        .raw("Remove&nbsp;yourself")
      )
    )
  )
}

private func teamMemberTemplate(_ email: EmailAddress, withRemoveButton: Bool) -> Node {
  return .gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .class([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.top: 1]]),
      ]),
      .style(lineHeight(0)),
    ],
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile),
        ])
      ],
      .img(
        base64: mailIconSvg,
        type: .image(.svg),
        alt: "",
        attributes: [
          .class([
            Class.margin([.mobile: [.right: 1]])
          ]),
          .style(width(.px(24)) <> height(.px(24))),
        ]
      ),
      .input(attributes: [
        .type(.email),
        .placeholder("blob@pointfree.co"),
        .class([Class.size.width100pct]),
        .name("teammate"),
        .style(
          borderWidth(all: 0)
            <> key("outline", "none")
        ),
        .value(email.rawValue),
      ]),
      withRemoveButton
        ? .a(
          attributes: [
            .class([
              Class.cursor.pointer,
              Class.pf.colors.fg.red,
              Class.pf.colors.link.red,
              Class.type.light,
              Class.pf.type.body.small,
              Class.pf.type.underlineLink,
            ]),
            .onclick(
              safe: """
                var teamMemberRow = this.parentNode.parentNode
                teamMemberRow.parentNode.removeChild(teamMemberRow)
                updateSeats()
                """),
          ], "Remove")
        : []
    )
  )
}

private func billingPeriod(
  coupon: Coupon?,
  lane: Pricing.Lane,
  subscribeData: SubscribeConfirmationData
) -> Node {

  let titleColumn = Node.gridColumn(
    sizes: [.mobile: 12],
    attributes: [.class([moduleTitleColumnClass])],
    .h1(attributes: [.class([moduleTitleClass])], "Billing interval")
  )

  let yearlyColumn = Node.gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .class([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
      ]),
      .style(lineHeight(0)),
    ],
    .label(
      attributes: [
        .class([
          Class.cursor.pointer,
          Class.flex.flex,
          Class.flex.items.baseline,
        ])
      ],
      .div(
        .input(
          attributes: [
            .checked(subscribeData.billing == .yearly),
            .id("yearly"),
            .type(.radio),
            .name("pricing[billing]"),
            .value("yearly"),
          ]
        )
      ),
      .div(
        attributes: [.class([Class.margin([.mobile: [.left: 2]])])],
        .h5(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle6,
              Class.margin([.mobile: [.all: 0]]),
            ])
          ],
          lane == .team
            ? "Yearly — Save 25% off monthly billing!"
            : "Yearly — Save 22% off monthly billing!"
        ),
        .p(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 1]]),
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray650,
            ])
          ],
          lane == .team
            ? "$144 per member per year"
            : discountedBillingIntervalSubtitle(
              interval: .year,
              coupon: coupon,
              useRegionalDiscount: subscribeData.useRegionalDiscount
            )
        )
      )
    )
  )

  let monthlyColumn = Node.gridColumn(
    sizes: [.mobile: 12],
    attributes: [
      .class([
        Class.border.left,
        Class.border.right,
        Class.border.bottom,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
      ]),
      .style(lineHeight(0)),
    ],
    .label(
      attributes: [
        .class([
          Class.cursor.pointer,
          Class.flex.flex,
          Class.flex.items.baseline,
        ])
      ],
      .div(
        .input(
          attributes: [
            .checked(subscribeData.billing == .monthly),
            .id("monthly"),
            .type(.radio),
            .name("pricing[billing]"),
            .value("monthly"),
          ]
        )
      ),
      .div(
        attributes: [.class([Class.margin([.mobile: [.left: 2]])])],
        .h5(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle6,
              Class.margin([.mobile: [.all: 0]]),
            ])
          ],
          "Monthly"
        ),
        .p(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 1]]),
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray650,
            ])
          ],
          lane == .team
            ? "$16 per member, per month"
            : discountedBillingIntervalSubtitle(
              interval: .month,
              coupon: coupon,
              useRegionalDiscount: subscribeData.useRegionalDiscount
            )
        )
      )
    )
  )

  return .gridRow(
    attributes: [.class([moduleRowClass])],
    titleColumn,
    yearlyColumn,
    monthlyColumn
  )
}

private func discountedBillingIntervalSubtitle(
  interval: Plan.Interval,
  coupon: Coupon?,
  useRegionalDiscount: Bool
) -> Node {
  let regionalFactor = useRegionalDiscount ? 0.5 : 1.0

  switch interval {
  case .month:
    let amount = Double(coupon?.discount(for: 18_00).rawValue ?? 18_00) / 100 * regionalFactor
    let formattedAmount = (currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(amount)")
      .replacingOccurrences(of: #"\.0{1,2}$"#, with: "", options: .regularExpression)
    return .text("\(formattedAmount) per month")
  case .year:
    let amount = Double(coupon?.discount(for: 168_00).rawValue ?? 168_00) / 100 * regionalFactor
    let formattedAmount = (currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(amount)")
      .replacingOccurrences(of: #"\.0{1,2}$"#, with: "", options: .regularExpression)
    return .text("\(formattedAmount) per year")
  }
}

private func payment(
  lane: Pricing.Lane,
  coupon: Stripe.Coupon?,
  stripeJs: String,
  stripePublishableKey: Stripe.Client.PublishableKey,
  referrer: User?,
  useRegionalDiscount: Bool
) -> Node {
  .gridRow(
    attributes: [.class([moduleRowClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([moduleTitleColumnClass])],
      .h1(attributes: [.class([moduleTitleClass])], "Payment info")
    ),

    .label(
      attributes: [
        .for("card"),
        .class([
          Class.type.nowrap,
          Class.pf.colors.fg.black,
          Class.pf.colors.bg.white,
          Class.pf.type.responsiveTitle6,
        ]),
      ],
      "Credit or debit card"
    ),

    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [
        .class([
          Class.border.all,
          Class.pf.colors.border.gray850,
          Class.padding([.mobile: [.all: 2]]),
          Class.margin([.mobile: [.top: 1]]),
        ]),
        .style(lineHeight(0)),
      ],
      .div(
        attributes: [.class([Class.flex.flex, Class.grid.middle(.mobile)])],
        .div(
          attributes: [
            .class([Class.size.width100pct]),
            .data("stripe-key", stripePublishableKey.rawValue),
            .id("card-element"),
          ]
        )
      )
    ),

    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [],
      .div(
        attributes: [
          .class([
            Class.pf.colors.fg.red,
            Class.pf.type.body.small,
          ]),
          .id("card-errors"),
        ]
      ),
      .input(
        attributes: [
          .name(SubscribeData.CodingKeys.paymentMethodID.rawValue),
          .type(.hidden),
        ]
      ),
      .script(attributes: [.src(stripeJs)]),
      .script(
        unsafe: checkoutJS(
          coupon: coupon,
          lane: lane,
          referrer: referrer,
          useRegionalDiscount: useRegionalDiscount
        )
      )
    ),

    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [
        .id("apple-pay-container"),
        .class([
          Class.margin([.mobile: [.left: 0]]),
          Class.padding([.mobile: [.top: 3]]),
          Class.display.none,
        ]),
        .style(lineHeight(0)),
      ],
      .label(
        attributes: [
          .for("apple-pay"),
          .class([
            Class.type.nowrap,
            Class.pf.colors.fg.black,
            Class.pf.colors.bg.white,
            Class.pf.type.responsiveTitle6,
          ]),
        ],
        "or Apple Pay"
      ),
      .div(
        attributes: [
          .id("payment-request-button"),
          .class([
            Class.grid.col(.mobile, 12),
            Class.grid.col(.desktop, 4),
            Class.margin([.mobile: [.top: 2]]),
          ]),
        ],
        []
      )
    )
  )
}

private func total(
  isLoggedIn: Bool,
  lane: Pricing.Lane,
  coupon: Stripe.Coupon?,
  referrer: User?,
  useRegionalDiscount: Bool
) -> Node {
  @Dependency(\.siteRouter) var siteRouter

  let discount = coupon?.discount(for:) ?? { $0 }
  let referralDiscount = referrer == nil ? 0 : 18

  return .gridRow(
    attributes: [
      .class([
        Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]]),
        Class.padding([.mobile: [.top: 3, .bottom: 4], .desktop: [.top: 3, .bottom: 4]]),
        Class.grid.middle(.mobile),
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
      .span(
        attributes: [
          .class([
            Class.pf.type.body.small,
            Class.pf.colors.fg.gray400,
          ]),
          .id("pricing-preview"),
        ]
      )
    ),
    .gridColumn(
      sizes: [:],
      attributes: [.class([Class.grid.start(.mobile)])],
      .div(
        attributes: [
          .class([
            Class.flex.flex,
            Class.flex.align.center,
            Class.grid.middle(.mobile),
          ])
        ],
        .h3(
          attributes: [
            .class([
              Class.pf.type.responsiveTitle2,
              Class.type.normal,
              Class.margin([.mobile: [.topBottom: 0]]),
            ]),
            .id("total"),
          ]
        ),
        .input(attributes: [
          .name("pricing[quantity]"),
          .type(.hidden),
        ]),
        .script(
          unsafe: #"""
            function format(money) {
              return "$" + money.toFixed(2).replace(/\.00$/, "")
            }
            function updateSeats() {
              var teamMembers = document.getElementById("team-members")
              var teamMemberInputs = teamMembers == null ? [] : Array.from(teamMembers.getElementsByTagName("INPUT"))
              for (var idx = 0; idx < teamMemberInputs.length; idx++) {
                teamMemberInputs[idx].name = "teammate"
              }
              var teamOwnerIsTakingSeat = document.getElementById("team-owner") != null
              var seats = teamMembers
                ? teamMembers.childNodes.length + (teamOwnerIsTakingSeat ? 1 : 0)
                : 1
              var form = document.getElementById("subscribe-form")
              form["pricing[quantity]"].value = seats
              var regionalDiscount = \#(useRegionalDiscount ? 0.5 : 1.0)
              var monthly = form["pricing[billing]"].value == "monthly"
              var monthlyPricePerSeat = (
                monthly
                  ? \#(discount(lane == .team ? 16_00 : 18_00)) * 0.01 * regionalDiscount
                  : \#(discount(lane == .team ? 12_00 : 14_00)) * 0.01 * regionalDiscount
              )
              const monthlyPrice = seats * monthlyPricePerSeat
              const total = monthly
                ? monthlyPrice
                : (monthlyPrice * 12 - \#(referralDiscount) * regionalDiscount)
              document.getElementById("total").textContent = format(total)
              document.getElementById("pricing-preview").innerHTML = (
                "You will be charged <strong>"
                  + format(monthlyPricePerSeat)
                  + " per month</strong>"
                  + (seats > 1 ? " times <strong>" + seats + " seats</strong>" : "")
                  + (monthly ? "" : " times <strong>12 months</strong>")
                  + "."
              )
              if (window.paymentRequest) {
                window.paymentRequest.update({
                  total: {
                    label: monthly ? "Monthly subscription" : "Yearly subscription",
                    amount: total * 100
                  }
                })
              }
            }
            window.addEventListener("load", function() {
              updateSeats()
              var form = document.getElementById("subscribe-form")
              form.addEventListener("change", updateSeats)
            })
            """#),
        .span(
          attributes: [
            .class([
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray400,
              Class.margin([.mobile: [.left: 1]]),
              Class.padding([.mobile: [.bottom: 1]]),
            ])
          ],
          "Total"
        )
      )
    ),
    .gridColumn(
      sizes: [:],
      attributes: [.class([Class.grid.end(.mobile)])],
      isLoggedIn
        ? .button(
          attributes: [
            .class([
              Class.border.none,
              Class.type.textDecorationNone,
              Class.cursor.pointer,
              Class.type.bold,
              Class.typeScale([.mobile: .r1, .desktop: .r1]),
              Class.padding([.mobile: [.topBottom: 2, .leftRight: 2]]),
              Class.type.align.center,
              Class.pf.colors.bg.black,
              Class.pf.colors.fg.white,
              Class.pf.colors.link.white,
            ])
          ],
          "Subscribe"
        )
        : .gitHubLink(
          text: "Log in to Subscribe",
          type: .black,
          href: siteRouter.loginPath(
            redirect: coupon.map { SiteRoute.discounts(code: $0.id, nil) }
              ?? .subscribeConfirmation(
                lane: lane,
                referralCode: referrer?.referralCode,
                useRegionalDiscount: useRegionalDiscount
              )
          )
        )
    )
  )
}

private let moduleTitleClass =
  Class.pf.type.responsiveTitle3
  | Class.margin([.mobile: [.top: 0]])

private let moduleTitleColumnClass =
  Class.padding([.mobile: [.bottom: 1], .desktop: [.bottom: 2]])

let moduleRowClass =
  Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]])
  | Class.padding([.mobile: [.topBottom: 3]])
  | Class.border.bottom
  | Class.pf.colors.border.gray850

public let currencyFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  // Workaround for https://bugs.swift.org/browse/SR-7481
  formatter.minimumIntegerDigits = 1
  formatter.numberStyle = .currency
  return formatter
}()

public struct DiscountCountry {
  public var countryCode: Stripe.Country
  public var name: String

  public static let all: [DiscountCountry] = [
    .init(countryCode: "AF", name: "Afghanistan"),
    .init(countryCode: "AL", name: "Albania"),
    .init(countryCode: "DZ", name: "Algeria"),
    .init(countryCode: "AO", name: "Angola"),
    .init(countryCode: "AG", name: "Antigua and Barbuda"),
    .init(countryCode: "AR", name: "Argentina"),
    .init(countryCode: "AM", name: "Armenia"),
    .init(countryCode: "BS", name: "Bahamas"),
    .init(countryCode: "BD", name: "Bangladesh"),
    .init(countryCode: "BB", name: "Barbados"),
    .init(countryCode: "BY", name: "Belarus"),
    .init(countryCode: "BM", name: "Bermuda"),
    .init(countryCode: "BZ", name: "Belize"),
    .init(countryCode: "BJ", name: "Benin"),
    .init(countryCode: "BO", name: "Bolivia"),
    .init(countryCode: "BW", name: "Botswana"),
    .init(countryCode: "BR", name: "Brazil"),
    .init(countryCode: "BG", name: "Bulgaria"),
    .init(countryCode: "BF", name: "Burkina Faso"),
    .init(countryCode: "BI", name: "Burundi"),
    .init(countryCode: "CM", name: "Cameroon"),
    .init(countryCode: "CV", name: "Cape Verde"),
    .init(countryCode: "CF", name: "Central African Republic"),
    .init(countryCode: "TD", name: "Chad"),
    .init(countryCode: "CL", name: "Chile"),
    .init(countryCode: "CO", name: "Colombia"),
    .init(countryCode: "KM", name: "Comoros"),
    .init(countryCode: "CG", name: "Democratic Republic of Congo"),
    .init(countryCode: "CR", name: "Costa Rica"),
    .init(countryCode: "HR", name: "Croatia"),
    .init(countryCode: "CU", name: "Cuba"),
    .init(countryCode: "DJ", name: "Djibouti"),
    .init(countryCode: "DM", name: "Dominica"),
    .init(countryCode: "DO", name: "Dominican Republic"),
    .init(countryCode: "EC", name: "Ecuador"),
    .init(countryCode: "EG", name: "Egypt"),
    .init(countryCode: "SV", name: "El Salvador"),
    .init(countryCode: "GQ", name: "Equatorial Guinea"),
    .init(countryCode: "ER", name: "Eritrea"),
    .init(countryCode: "ET", name: "Ethiopia"),
    .init(countryCode: "FK", name: "Falkland Islands"),
    .init(countryCode: "GF", name: "French Guiana"),
    .init(countryCode: "GA", name: "Gabon"),
    .init(countryCode: "GM", name: "Gambia"),
    .init(countryCode: "GE", name: "Georgia"),
    .init(countryCode: "GH", name: "Ghana"),
    .init(countryCode: "GD", name: "Grenada"),
    .init(countryCode: "GT", name: "Guatemala"),
    .init(countryCode: "GN", name: "Guinea"),
    .init(countryCode: "GW", name: "Guinea-Bissau"),
    .init(countryCode: "GY", name: "Guyana"),
    .init(countryCode: "HT", name: "Haiti"),
    .init(countryCode: "HN", name: "Honduras"),
    .init(countryCode: "IN", name: "India"),
    .init(countryCode: "ID", name: "Indonesia"),
    .init(countryCode: "CI", name: "Ivory Coast"),
    .init(countryCode: "JM", name: "Jamaica"),
    .init(countryCode: "JO", name: "Jordan"),
    .init(countryCode: "KZ", name: "Kazakhstan"),
    .init(countryCode: "KE", name: "Kenya"),
    .init(countryCode: "LA", name: "Laos"),
    .init(countryCode: "LS", name: "Lesotho"),
    .init(countryCode: "LR", name: "Liberia"),
    .init(countryCode: "LY", name: "Libya"),
    .init(countryCode: "MK", name: "Macedonia"),
    .init(countryCode: "MG", name: "Madagascar"),
    .init(countryCode: "MW", name: "Malawi"),
    .init(countryCode: "ML", name: "Mali"),
    .init(countryCode: "MR", name: "Mauritania"),
    .init(countryCode: "MU", name: "Mauritius"),
    .init(countryCode: "MA", name: "Morocco"),
    .init(countryCode: "MZ", name: "Mozambique"),
    .init(countryCode: "MM", name: "Myanmar"),
    .init(countryCode: "NA", name: "Namibia"),
    .init(countryCode: "NP", name: "Nepal"),
    .init(countryCode: "NI", name: "Nicaragua"),
    .init(countryCode: "NE", name: "Niger"),
    .init(countryCode: "NG", name: "Nigeria"),
    .init(countryCode: "PK", name: "Pakistan"),
    .init(countryCode: "PA", name: "Panama"),
    .init(countryCode: "PY", name: "Paraguay"),
    .init(countryCode: "PE", name: "Peru"),
    .init(countryCode: "PH", name: "Philippines"),
    .init(countryCode: "PS", name: "Palestine"),
    .init(countryCode: "RW", name: "Rwanda"),
    .init(countryCode: "SN", name: "Senegal"),
    .init(countryCode: "RS", name: "Serbia"),
    .init(countryCode: "SC", name: "Seychelles"),
    .init(countryCode: "SL", name: "Sierra Leone"),
    .init(countryCode: "SO", name: "Somalia"),
    .init(countryCode: "ZA", name: "South Africa"),
    .init(countryCode: "GS", name: "South Georgia"),
    .init(countryCode: "SD", name: "Sudan"),
    .init(countryCode: "SR", name: "Suriname"),
    .init(countryCode: "LK", name: "Sri Lanka"),
    .init(countryCode: "SZ", name: "Swaziland"),
    .init(countryCode: "TZ", name: "Tanzania"),
    .init(countryCode: "TG", name: "Togo"),
    .init(countryCode: "TR", name: "Turkey"),
    .init(countryCode: "TT", name: "Trinidad and Tobago"),
    .init(countryCode: "TN", name: "Tunisia"),
    .init(countryCode: "UG", name: "Uganda"),
    .init(countryCode: "UA", name: "Ukraine"),
    .init(countryCode: "UY", name: "Uruguay"),
    .init(countryCode: "VE", name: "Venezuela"),
    .init(countryCode: "VN", name: "Vietnam"),
    .init(countryCode: "EH", name: "Western Sahara"),
    .init(countryCode: "YE", name: "Yemen"),
    .init(countryCode: "ZM", name: "Zambia"),
    .init(countryCode: "ZW", name: "Zimbabwe"),
  ]
}

private func checkoutJS(
  coupon: Stripe.Coupon?,
  lane: Pricing.Lane,
  referrer: User?,
  useRegionalDiscount: Bool
) -> String {
  return """
    window.addEventListener("load", function() {
      var form = document.getElementById("subscribe-form")
      var displayError = document.getElementById("card-errors")

      var apiKey = document.getElementById("card-element").dataset.stripeKey
      var stripe = Stripe(apiKey, { apiVersion: "2020-08-27" })
      var elements = stripe.elements()
      var style = {
        base: {
          fontSize: "16px",
        }
      }

      window.paymentRequest = stripe.paymentRequest({
        country: 'US',
        currency: 'usd',
        total: { label: '', amount: 100, }
      });
      const paymentRequestButton = elements.create('paymentRequestButton', {
        paymentRequest: window.paymentRequest,
      });

      var card = elements.create("card", { style: style })
      card.mount("#card-element")
      card.addEventListener("change", function(event) {
        if (event.error) {
          displayError.textContent = event.error.message
        } else {
          displayError.textContent = ""
        }
      });

      window.paymentRequest.on('paymentmethod', async (ev) => {
        setFormEnabled(false, function() { return true })
        ev.complete('success')
        form.\(SubscribeData.CodingKeys.paymentMethodID.rawValue).value = ev.paymentMethod.id
        setFormEnabled(true, function(el) { return el.tagName != "BUTTON" })
        form.submit()
      });

      function setFormEnabled(isEnabled, elementsMatching) {
        for (var idx = 0; idx < form.length; idx++) {
          var formElement = form[idx]
          if (elementsMatching(formElement)) {
            formElement.disabled = !isEnabled
            if (formElement.tagName == "BUTTON") {
              formElement.textContent = isEnabled ? "Subscribe" : "Subscribing…"
            }
          }
        }
      }

      var submitting = false
      form.addEventListener("submit", async (event) => {
        event.preventDefault()
        if (submitting) { return }

        displayError.textContent = ""
        submitting = true
        setFormEnabled(false, function() { return true })

        try {
          const result = await stripe.createPaymentMethod({
            type: 'card',
            card: card,
          })
          if (result.error) {
            displayError.textContent = result.error.message
          } else {
            form.\(SubscribeData.CodingKeys.paymentMethodID.rawValue).value = result.paymentMethod.id
            setFormEnabled(true, function(el) { return el.tagName != "BUTTON" })
            form.submit()
            return // NB: Early out so to not re-enable form.
          }
        } catch {
          displayError.innerHTML = "An error occurred. Please try again or contact <a href='mailto:support@pointfree.co'>support@pointfree.co</a>."
        }

        submitting = false
        setFormEnabled(true, function(el) { return true })
      });

      (async () => {
        const result = await window.paymentRequest.canMakePayment();
        if (result) {
          paymentRequestButton.mount('#payment-request-button');
          document.getElementById("apple-pay-container").style.display = 'block'
          updateSeats()
        } else {
          document.getElementById('payment-request-button').style.display = 'none';
        }
      })();
    })
    """
}
