import Css
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
  return .form(
    attributes: [
      .action(path(to: .subscribe(nil))),
      .id("subscribe-form"),
      .method(.post),
      .onsubmit(unsafe: "event.preventDefault()"),
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
    currentUser.map { teamMembers(lane: lane, currentUser: $0, subscribeData: subscribeData) } ?? [],
    billingPeriod(coupon: coupon, lane: lane, subscribeData: subscribeData),
    currentUser != nil
      ? payment(lane: lane, coupon: coupon, stripeJs: stripeJs, stripePublishableKey: stripePublishableKey)
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
      ])
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
          .value(coupon.id.rawValue)
        ]
      )
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
        .value("\(useRegionalDiscount)")
      ]
    )
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
        .class([Class.margin([.mobile: [.top: 2]]), Class.padding([.mobile: [.all: 2]])])
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
            Class.pf.type.underlineLink
          ]),
          .href(url(to: .pricingLanding))
        ],
        "Change plan"
      )
    ),
    planFeatures(
      currentUser: currentUser,
      episodeStats: episodeStats,
      lane: lane
    ),
    additionalDiscountInfo(referrer: referrer, coupon: coupon, useRegionalDiscount: useRegionalDiscount)
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
    )
  ]
}

private func planFeatures(
  currentUser: User?,
  episodeStats: EpisodeStats,
  lane: Pricing.Lane
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
          Class.pf.colors.fg.gray400
        ]),
        .style(flex(grow: 1, shrink: 0, basis: .auto))
      ],
      .fragment(
        PricingPlan.personal(
          allEpisodeCount: episodeStats.allEpisodeCount,
          episodeHourCount: episodeStats.episodeHourCount
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
      .value("true")
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
            .onclick(safe: """
var teamMember = document.getElementById("team-member-template").content.cloneNode(true)
document.getElementById("team-members").appendChild(teamMember)
updateSeats()
""")
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
          Class.padding([.mobile: [.top: 3]])
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
      .value("false")
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
      .style(lineHeight(0))
    ],
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile)
        ])
      ],
      .input(
        attributes: [
          .name(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue),
          .type(.hidden),
          .value("true")
        ]
      ),
      .img(
        src: currentUser.gitHubAvatarUrl.absoluteString,
        alt: "",
        attributes: [
          .class([
            Class.pf.colors.bg.green,
            Class.border.circle,
            Class.margin([.mobile: [.right: 1]])
          ]),
          .style(width(.px(24)) <> height(.px(24)))
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
            Class.pf.type.underlineLink
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
          )
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
        Class.margin([.mobile: [.top: 1]])
      ]),
      .style(lineHeight(0))
    ],
    .div(
      attributes: [
        .class([
          Class.flex.flex,
          Class.grid.middle(.mobile)
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
          .style(width(.px(24)) <> height(.px(24)))
        ]
      ),
      .input(attributes: [
        .type(.email),
        .placeholder("blob@pointfree.co"),
        .class([Class.size.width100pct]),
        .name("teammates[]"),
        .style(
          borderWidth(all: 0)
            <> key("outline", "none")
        ),
        .value(email.rawValue),
      ]),
      withRemoveButton
        ? .a(attributes: [
          .class([
            Class.cursor.pointer,
            Class.pf.colors.fg.red,
            Class.pf.colors.link.red,
            Class.type.light,
            Class.pf.type.body.small,
            Class.pf.type.underlineLink
          ]),
          .onclick(safe: """
var teamMemberRow = this.parentNode.parentNode
teamMemberRow.parentNode.removeChild(teamMemberRow)
updateSeats()
""")
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
        Class.padding([.mobile: [.all: 2]])
      ]),
      .style(lineHeight(0))
    ],
    .label(
      attributes: [
        .class([
          Class.cursor.pointer,
          Class.flex.flex,
          Class.flex.items.baseline
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
              Class.margin([.mobile: [.all: 0]])
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
              Class.pf.colors.fg.gray650
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
        Class.padding([.mobile: [.all: 2]])
      ]),
      .style(lineHeight(0))
    ],
    .label(
      attributes: [
        .class([
          Class.cursor.pointer,
          Class.flex.flex,
          Class.flex.items.baseline
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
              Class.margin([.mobile: [.all: 0]])
            ])
          ],
          "Monthly"
        ),
        .p(
          attributes: [
            .class([
              Class.padding([.mobile: [.top: 1]]),
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray650
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
    let formattedAmount = (currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(amount)").replacingOccurrences(of: #"\.0{1,2}$"#, with: "", options: .regularExpression)
    return .text("\(formattedAmount) per month")
  case .year:
    let amount = Double(coupon?.discount(for: 168_00).rawValue ?? 168_00) / 100 * regionalFactor
    let formattedAmount = (currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(amount)").replacingOccurrences(of: #"\.0{1,2}$"#, with: "", options: .regularExpression)
    return .text("\(formattedAmount) per year")
  }
}

private func payment(
  lane: Pricing.Lane,
  coupon: Stripe.Coupon?,
  stripeJs: String,
  stripePublishableKey: Stripe.Client.PublishableKey
) -> Node {
  return .gridRow(
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
          Class.margin([.mobile: [.top: 1]])
        ]),
        .style(lineHeight(0))
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
          .name("token"),
          .type(.hidden)
        ]
      ),
      .script(attributes: [.src(stripeJs)]),
      .script(safe: """
window.addEventListener("load", function() {
    var apiKey = document.getElementById("card-element").dataset.stripeKey
  var stripe = Stripe(apiKey)
  var elements = stripe.elements()
  var style = {
    base: {
      fontSize: "16px",
    }
  }
  var card = elements.create("card", { style: style })
  card.mount("#card-element")
  var displayError = document.getElementById("card-errors")
  card.addEventListener("change", function(event) {
    if (event.error) {
      displayError.textContent = event.error.message
    } else {
      displayError.textContent = ""
    }
  });
  var form = document.getElementById("subscribe-form")
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
  form.addEventListener("submit", function(event) {
    event.preventDefault()
    setFormEnabled(false, function() { return true })
    stripe.createToken(card).then(function(result) {
      if (result.error) {
        displayError.textContent = result.error.message
        setFormEnabled(true, function(el) { return true })
      } else {
          setFormEnabled(true, function(el) { return el.tagName != "BUTTON" })
        form.token.value = result.token.id
        form.submit()
      }
    }).catch(function() {
      setFormEnabled(true, function(el) { return true })
    })
  })
})
""")
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
  let discount = coupon?.discount(for:) ?? { $0 }
  let referralDiscount = referrer == nil ? 0 : 18
  return .gridRow(
    attributes: [
      .class([
        Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]]),
        Class.padding([.mobile: [.top: 3, .bottom: 4], .desktop: [.top: 3, .bottom: 4]]),
        Class.grid.middle(.mobile)
      ])
    ],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([Class.padding([.mobile: [.bottom: 4]])])],
      .span(
        attributes: [
          .class([
            Class.pf.type.body.small,
            Class.pf.colors.fg.gray400
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
              Class.margin([.mobile: [.topBottom: 0]])
            ]),
            .id("total"),
          ]
        ),
        .input(attributes: [
          .name("pricing[quantity]"),
          .type(.hidden),
        ]),
        .script(unsafe: #"""
function format(money) {
  return "$" + money.toFixed(2).replace(/\.00$/, "")
}
function updateSeats() {
  var teamMembers = document.getElementById("team-members")
  var teamMemberInputs = teamMembers == null ? [] : Array.from(teamMembers.getElementsByTagName("INPUT"))
  for (var idx = 0; idx < teamMemberInputs.length; idx++) {
    teamMemberInputs[idx].name = "teammates[" + idx + "]"
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
  var monthlyPrice = seats * monthlyPricePerSeat
  document.getElementById("total").textContent = format(
    monthly
      ? monthlyPrice
      : (monthlyPrice * 12 - \#(referralDiscount))
  )
  document.getElementById("pricing-preview").innerHTML = (
    "You will be charged <strong>"
      + format(monthlyPricePerSeat)
      + " per month</strong>"
      + (seats > 1 ? " times <strong>" + seats + " seats</strong>" : "")
      + (monthly ? "" : " times <strong>12 months</strong>")
      + "."
  )
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
              Class.padding([.mobile: [.bottom: 1]])
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
          href: path(
            to: .login(
              redirect: url(
                to: coupon
                  .map { Route.discounts(code: $0.id, nil) }
                  ?? .subscribeConfirmation(
                    lane: lane,
                    billing: nil,
                    isOwnerTakingSeat: nil,
                    teammates: nil,
                    referralCode: referrer?.referralCode,
                    useRegionalDiscount: useRegionalDiscount
                )
              )
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
  public var countryCode: Stripe.Card.Country
  public var name: String

  public static let all = [
    DiscountCountry(countryCode: "AF", name: "Afghanistan"),
    DiscountCountry(countryCode: "AL", name: "Albania"),
    DiscountCountry(countryCode: "DZ", name: "Algeria"),
    DiscountCountry(countryCode: "AO", name: "Angola"),
    DiscountCountry(countryCode: "AG", name: "Antigua and Barbuda"),
    DiscountCountry(countryCode: "AR", name: "Argentina"),
    DiscountCountry(countryCode: "BS", name: "Bahamas"),
    DiscountCountry(countryCode: "BD", name: "Bangladesh"),
    DiscountCountry(countryCode: "BB", name: "Barbados"),
    DiscountCountry(countryCode: "BY", name: "Belarus"),
    DiscountCountry(countryCode: "BM", name: "Bermuda"),
    DiscountCountry(countryCode: "BZ", name: "Belize"),
    DiscountCountry(countryCode: "BJ", name: "Benin"),
    DiscountCountry(countryCode: "BO", name: "Bolivia"),
    DiscountCountry(countryCode: "BW", name: "Botswana"),
    DiscountCountry(countryCode: "BR", name: "Brazil"),
    DiscountCountry(countryCode: "BG", name: "Bulgaria"),
    DiscountCountry(countryCode: "BF", name: "Burkina Faso"),
    DiscountCountry(countryCode: "BI", name: "Burundi"),
    DiscountCountry(countryCode: "CM", name: "Cameroon"),
    DiscountCountry(countryCode: "CV", name: "Cape Verde"),
    DiscountCountry(countryCode: "CF", name: "Central African Republic"),
    DiscountCountry(countryCode: "TD", name: "Chad"),
    DiscountCountry(countryCode: "CL", name: "Chile"),
    DiscountCountry(countryCode: "CO", name: "Colombia"),
    DiscountCountry(countryCode: "KM", name: "Comoros"),
    DiscountCountry(countryCode: "CG", name: "Democratic Republic of Congo"),
    DiscountCountry(countryCode: "CR", name: "Costa Rica"),
    DiscountCountry(countryCode: "HR", name: "Croatia"),
    DiscountCountry(countryCode: "CU", name: "Cuba"),
    DiscountCountry(countryCode: "DJ", name: "Djibouti"),
    DiscountCountry(countryCode: "DM", name: "Dominica"),
    DiscountCountry(countryCode: "DO", name: "Dominican Republic"),
    DiscountCountry(countryCode: "EC", name: "Ecuador"),
    DiscountCountry(countryCode: "EG", name: "Egypt"),
    DiscountCountry(countryCode: "SV", name: "El Salvador"),
    DiscountCountry(countryCode: "GQ", name: "Equatorial Guinea"),
    DiscountCountry(countryCode: "ER", name: "Eritrea"),
    DiscountCountry(countryCode: "ET", name: "Ethiopia"),
    DiscountCountry(countryCode: "FK", name: "Falkland Islands"),
    DiscountCountry(countryCode: "GF", name: "French Guiana"),
    DiscountCountry(countryCode: "GA", name: "Gabon"),
    DiscountCountry(countryCode: "GM", name: "Gambia"),
    DiscountCountry(countryCode: "GH", name: "Ghana"),
    DiscountCountry(countryCode: "GD", name: "Grenada"),
    DiscountCountry(countryCode: "GT", name: "Guatemala"),
    DiscountCountry(countryCode: "GN", name: "Guinea"),
    DiscountCountry(countryCode: "GW", name: "Guinea-Bissau"),
    DiscountCountry(countryCode: "GY", name: "Guyana"),
    DiscountCountry(countryCode: "HT", name: "Haiti"),
    DiscountCountry(countryCode: "HN", name: "Honduras"),
    DiscountCountry(countryCode: "IN", name: "India"),
    DiscountCountry(countryCode: "ID", name: "Indonesia"),
    DiscountCountry(countryCode: "CI", name: "Ivory Coast"),
    DiscountCountry(countryCode: "JM", name: "Jamaica"),
    DiscountCountry(countryCode: "KE", name: "Kenya"),
    DiscountCountry(countryCode: "LA", name: "Laos"),
    DiscountCountry(countryCode: "LS", name: "Lesotho"),
    DiscountCountry(countryCode: "LR", name: "Liberia"),
    DiscountCountry(countryCode: "LY", name: "Libya"),
    DiscountCountry(countryCode: "MK", name: "Macedonia"),
    DiscountCountry(countryCode: "MG", name: "Madagascar"),
    DiscountCountry(countryCode: "MW", name: "Malawi"),
    DiscountCountry(countryCode: "ML", name: "Mali"),
    DiscountCountry(countryCode: "MR", name: "Mauritania"),
    DiscountCountry(countryCode: "MU", name: "Mauritius"),
    DiscountCountry(countryCode: "MA", name: "Morocco"),
    DiscountCountry(countryCode: "MZ", name: "Mozambique"),
    DiscountCountry(countryCode: "MM", name: "Myanmar"),
    DiscountCountry(countryCode: "NA", name: "Namibia"),
    DiscountCountry(countryCode: "NP", name: "Nepal"),
    DiscountCountry(countryCode: "NI", name: "Nicaragua"),
    DiscountCountry(countryCode: "NE", name: "Niger"),
    DiscountCountry(countryCode: "NG", name: "Nigeria"),
    DiscountCountry(countryCode: "PK", name: "Pakistan"),
    DiscountCountry(countryCode: "PA", name: "Panama"),
    DiscountCountry(countryCode: "PY", name: "Paraguay"),
    DiscountCountry(countryCode: "PE", name: "Peru"),
    DiscountCountry(countryCode: "PH", name: "Philippines"),
    DiscountCountry(countryCode: "RW", name: "Rwanda"),
    DiscountCountry(countryCode: "SN", name: "Senegal"),
    DiscountCountry(countryCode: "SC", name: "Seychelles"),
    DiscountCountry(countryCode: "SL", name: "Sierra Leone"),
    DiscountCountry(countryCode: "SO", name: "Somalia"),
    DiscountCountry(countryCode: "ZA", name: "South Africa"),
    DiscountCountry(countryCode: "GS", name: "South Georgia"),
    DiscountCountry(countryCode: "SD", name: "Sudan"),
    DiscountCountry(countryCode: "SR", name: "Suriname"),
    DiscountCountry(countryCode: "SZ", name: "Swaziland"),
    DiscountCountry(countryCode: "TZ", name: "Tanzania"),
    DiscountCountry(countryCode: "TG", name: "Togo"),
    DiscountCountry(countryCode: "TT", name: "Trinidad and Tobago"),
    DiscountCountry(countryCode: "TN", name: "Tunisia"),
    DiscountCountry(countryCode: "UG", name: "Uganda"),
    DiscountCountry(countryCode: "UA", name: "Ukraine"),
    DiscountCountry(countryCode: "UY", name: "Uruguay"),
    DiscountCountry(countryCode: "VE", name: "Venezuela"),
    DiscountCountry(countryCode: "VN", name: "Vietnam"),
    DiscountCountry(countryCode: "EH", name: "Western Sahara"),
    DiscountCountry(countryCode: "YE", name: "Yemen"),
    DiscountCountry(countryCode: "ZM", name: "Zambia"),
    DiscountCountry(countryCode: "ZW", name: "Zimbabwe"),
  ]
}
