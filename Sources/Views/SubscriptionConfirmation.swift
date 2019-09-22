import Css
import FunctionalCss
import HtmlUpgrade
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
  _ lane: Pricing.Lane,
  _ subscribeData: SubscribeConfirmationData,
  _ coupon: Stripe.Coupon?,
  _ currentUser: User,
  _ stripeJs: String,
  _ stripePublishableKey: Stripe.Client.PublishableKey
) -> Node {
  return .form(
    attributes: [
      .action(path(to: .subscribe(nil))),
      .id("subscribe-form"),
      .method(.post),
      .onsubmit(unsafe: "event.preventDefault()"),
      .style(maxWidth(.px(900)) <> margin(leftRight: .auto)),
    ],
    header(lane),
    teamMembers(lane: lane, currentUser: currentUser, subscribeData: subscribeData),
    billingPeriod(coupon: coupon, lane: lane, subscribeData: subscribeData),
    payment(lane: lane, coupon: coupon, stripeJs: stripeJs, stripePublishableKey: stripePublishableKey),
    total(lane: lane, coupon: coupon)
  )
}

private func header(_ lane: Pricing.Lane) -> Node {
  return [
    .input(
      attributes: [
        .name("pricing[lane]"),
        .type(.hidden),
        .value(lane.rawValue),
      ]
    ),
    .gridRow(
      attributes: [.class([moduleRowClass])],
      .gridColumn(
        sizes: [.mobile: 12],
        .h1(attributes: [.class([Class.pf.type.responsiveTitle2])], "Subscribe")
      ),
      .gridColumn(
        sizes: [:],
        attributes: [.class([Class.grid.start(.mobile)])],
        "You selected the ",
        .strong([lane == .personal ? "Personal" : "Team"]),
        " plan"
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
      )
    )
  ]
}

private func teamMembers(
  lane: Pricing.Lane,
  currentUser: User,
  subscribeData: SubscribeConfirmationData
  ) -> Node {

  guard lane == .team else {
    return [
      .input(attributes: [
        .name(SubscribeData.CodingKeys.isOwnerTakingSeat.rawValue),
        .type(.hidden),
        .value("true")
        ])
    ]
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
  return .gridRow(
    attributes: [.class([moduleRowClass])],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([moduleTitleColumnClass])],
      .h1(attributes: [.class([moduleTitleClass])], "Billing interval")
    ),
    .gridColumn(
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
              ? "Yearly — 25% off!"
              : "Yearly — 22% off!"
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
              : discountedBillingIntervalSubtitle(interval: .year, coupon: coupon)
          )
        )
      )
    ),
    .gridColumn(
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
              : discountedBillingIntervalSubtitle(interval: .month, coupon: coupon)
          )
        )
      )
    )
  )
}

private func discountedBillingIntervalSubtitle(interval: Plan.Interval, coupon: Coupon?) -> Node {
  switch interval {
  case .month:
    let dollars = (coupon?.discount(for: 18_00).rawValue ?? 18_00) / 100
    return .text("$\(dollars) per month")
  case .year:
    let dollars = (coupon?.discount(for: 168_00).rawValue ?? 168_00) / 100
    return .text("$\(dollars) per year")
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
    ),
    coupon.map(discount) ?? [],
    .gridColumn(
      sizes: [.mobile: 12],
      attributes: [.class([Class.padding([.mobile: [.top: 3, .bottom: 2]])])],
      .span(
        attributes: [
          .class([
            Class.pf.type.body.small,
            Class.pf.colors.fg.gray400
            ]),
          .id("pricing-preview"),
        ]
      ),
      discountedTotalDisclaimer(coupon: coupon)
    )
  )
}

private func discountedTotalDisclaimer(coupon: Coupon?) -> Node {
  guard let coupon = coupon else { return [] }

  return .span(
    attributes: [
      .class([
        Class.pf.type.body.small,
        Class.border.none,
        Class.pf.colors.fg.gray400
        ]),
    ],
    coupon.name
      .map { [" You are using the coupon ", .strong(.text($0))] }
      ?? " You are using a coupon",
    ", which gives you \(coupon.formattedDescription) every billing period."
  )
}

private func discount(coupon: Stripe.Coupon) -> Node {
  return .input(
    attributes: [
      .class([Class.display.none]),
      .disabled(true),
      .name("coupon"),
      .placeholder("Coupon Code"),
      .type(.hidden),
      .value(coupon.id.rawValue)
    ]
  )
}

private func total(lane: Pricing.Lane, coupon: Stripe.Coupon?) -> Node {
  let discount = coupon?.discount ?? { $0 }
  return .gridRow(
    attributes: [
      .class([
        Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]]),
        Class.padding([.mobile: [.top: 3, .bottom: 4], .desktop: [.top: 3, .bottom: 4]]),
        Class.grid.middle(.mobile)
        ])
    ],
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
  var monthly = form["pricing[billing]"].value == "monthly"
  var monthlyPricePerSeat = (
    monthly
      ? \#(discount(lane == .team ? 16_00 : 18_00)) * 0.01
      : \#(discount(lane == .team ? 12_00 : 14_00)) * 0.01
  )
  var monthlyPrice = seats * monthlyPricePerSeat
  document.getElementById("total").textContent = format(
    monthly
      ? monthlyPrice
      : monthlyPrice * 12
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
      .button(
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
    )
  )
}

let moduleTitleClass =
  Class.pf.type.responsiveTitle3
    | Class.margin([.mobile: [.top: 0]])

let moduleTitleColumnClass =
  Class.padding([.mobile: [.bottom: 1], .desktop: [.bottom: 2]])

let moduleRowClass =
  Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]])
    | Class.padding([.mobile: [.topBottom: 3]])
    | Class.border.bottom
    | Class.pf.colors.border.gray850
