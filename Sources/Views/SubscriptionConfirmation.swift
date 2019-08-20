import Css
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
  _ lane: Pricing.Lane,
  _ subscribeData: SubscribeData?,
  _ coupon: Stripe.Coupon?,
  _ currentUser: User,
  _ stripeJs: String,
  _ stripePublishableKey: String
) -> [Node] {
  return [
    form(
      [
        action(path(to: .subscribe(nil))),
        id("subscribe-form"),
        method(.post),
        onsubmit("event.preventDefault()"),
        style(maxWidth(.px(900)) <> margin(leftRight: .auto)),
      ],
      header(lane)
        + (lane == .team ? teamMembers(currentUser, subscribeData) : [])
        + billingPeriod(lane, subscribeData)
        + payment(lane: lane, coupon: coupon, stripeJs: stripeJs, stripePublishableKey: stripePublishableKey)
        + total(lane: lane, coupon: coupon)
    )
  ]
}

private func header(_ lane: Pricing.Lane) -> [Node] {
  return [
    input([
      name("pricing[lane]"),
      type(.hidden),
      value(lane.rawValue),
    ]),
    gridRow(
      [`class`([moduleRowClass])],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [h1([`class`([Class.pf.type.responsiveTitle2])], ["Subscribe"])]
        ),
        gridColumn(
          sizes: [:],
          [`class`([Class.grid.start(.mobile)])],
          [
            "You selected the ",
            strong([lane == .personal ? "Personal" : "Team"]),
            " plan"
          ]
        ),
        gridColumn(
          sizes: [:],
          [`class`([Class.grid.end(.mobile)])],
          [
            a(
              [
                `class`([
                  Class.pf.colors.link.gray650,
                  Class.pf.type.underlineLink
                ]),
                href(url(to: .pricingLanding))
              ],
              ["Change plan"]
            )
          ]
        )
      ]
    )
  ]
}

private func teamMembers(_ currentUser: User, _ subscribeData: SubscribeData?) -> [Node] {
  return [
    gridRow(
      [`class`([moduleRowClass])],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [`class`([moduleTitleColumnClass])],
          [h1([`class`([moduleTitleClass])], ["Team members"])]
        ),
        teamOwner(currentUser),
        gridColumn(
          sizes: [.mobile: 12],
          [id("team-members")],
          (subscribeData?.teammates ?? [""])
            .map { teamMemberTemplate($0, withRemoveButton: false) }
        ),
        gridColumn(
          sizes: [.mobile: 12],
          [
            `class`([Class.padding([.mobile: [.top: 3]])])
          ],
          [
            div(
              [],
              [
                .element(
                  "template",
                  [("id", "team-member-template")],
                  [teamMemberTemplate("", withRemoveButton: true)]
                ),
                a(
                  [
                    id("add-team-member-button"),
                    `class`([
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
                    onclick("""
var teamMember = document.getElementById("team-member-template").content.cloneNode(true)
document.getElementById("team-members").appendChild(teamMember)
updateSeats()
""")
                  ],
                  ["Add team member"]
                )
              ]
            )
          ]
        ),
        p(
          [
            `class`([
              Class.pf.type.body.small,
              Class.pf.colors.fg.gray400,
              Class.padding([.mobile: [.top: 3]])
              ])
          ],
          [
            "You can add additional team members at anytime from your account page."
          ]
        )
      ]
    )
  ]
}

private func teamOwner(_ currentUser: User) -> Node {
  return gridColumn(
    sizes: [.mobile: 12],
    [
      `class`([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]])
        ]),
      HtmlCssSupport.style(lineHeight(0))
    ],
    [
      div(
        [
          `class`([
            Class.flex.flex,
            Class.grid.middle(.mobile)
            ])
        ],
        [
          img(
            src: currentUser.gitHubAvatarUrl.absoluteString,
            alt: "",
            [
              `class`([
                Class.pf.colors.bg.green,
                Class.border.circle,
                Class.margin([.mobile: [.right: 1]])
                ]),
              style(width(.px(24)) <> height(.px(24)))
            ]
          ),
          span([.text(currentUser.displayName)])
        ]
      )
    ]
  )
}

private func teamMemberTemplate(_ email: EmailAddress, withRemoveButton: Bool) -> Node {
  return gridColumn(
    sizes: [.mobile: 12],
    [
      `class`([
        Class.border.all,
        Class.pf.colors.border.gray850,
        Class.padding([.mobile: [.all: 2]]),
        Class.margin([.mobile: [.top: 1]])
        ]),
      HtmlCssSupport.style(lineHeight(0))
    ],
    [
      div(
        [
          `class`([
            Class.flex.flex,
            Class.grid.middle(.mobile)
            ])
        ],
        [
          img(
            base64: mailIconSvg,
            type: .image(.svg),
            alt: "",
            [
              `class`([
                Class.margin([.mobile: [.right: 1]])
                ]),
              style(width(.px(24)) <> height(.px(24)))
            ]
          ),
          input([
            type(.email),
            placeholder("blob@pointfree.co"),
            `class`([Class.size.width100pct]),
            name("teammates[]"),
            style(
              borderWidth(all: 0)
                <> key("outline", "none")
            ),
            value(email.rawValue),
          ]),
          ] + (withRemoveButton
            ? [
              a([
                `class`([
                  Class.cursor.pointer,
                  Class.pf.colors.fg.red,
                  Class.pf.colors.link.red,
                  Class.type.light,
                  Class.pf.type.body.small,
                  Class.pf.type.underlineLink
                ]),
                onclick("""
var teamMemberRow = this.parentNode.parentNode
teamMemberRow.parentNode.removeChild(teamMemberRow)
updateSeats()
""")
              ], ["Remove"])
              ]
            : []
        )
      )
    ]
  )
}

private func billingPeriod(_ lane: Pricing.Lane, _ subscribeData: SubscribeData?) -> [Node] {
  return [
    gridRow(
      [`class`([moduleRowClass])],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [`class`([moduleTitleColumnClass])],
          [h1([`class`([moduleTitleClass])], ["Billing interval"])]
        ),
        gridColumn(
          sizes: [.mobile: 12],
          [
            `class`([
              Class.border.all,
              Class.pf.colors.border.gray850,
              Class.padding([.mobile: [.all: 2]])
              ]),
            HtmlCssSupport.style(lineHeight(0))
          ],
          [
            label(
              [
                `class`([
                  Class.cursor.pointer,
                  Class.flex.flex,
                  Class.flex.items.baseline
                ])
              ],
              [
                div([
                  input([
                    checked((subscribeData?.pricing.billing ?? .yearly) == .yearly),
                    id("yearly"),
                    type(.radio),
                    name("pricing[billing]"),
                    value("yearly"),
                  ])
                ]),
                div(
                  [
                    `class`([Class.margin([.mobile: [.left: 2]])]),
                  ],
                  [
                    h5(
                      [
                        `class`([
                          Class.pf.type.responsiveTitle6,
                          Class.margin([.mobile: [.all: 0]])
                          ])
                      ],
                      [
                        lane == .team
                          ? "Yearly — 25% off!"
                          : "Yearly — 22% off!"
                      ]
                    ),
                    p(
                      [
                        `class`([
                          Class.padding([.mobile: [.top: 1]]),
                          Class.pf.type.body.small,
                          Class.pf.colors.fg.gray650
                          ])
                      ],
                      [
                        lane == .team
                          ? "$144 per member per year"
                          : "$168 per year"
                      ]
                    )
                  ]
                )
              ]
            )
          ]
        ),
        gridColumn(
          sizes: [.mobile: 12],
          [
            `class`([
              Class.border.left,
              Class.border.right,
              Class.border.bottom,
              Class.pf.colors.border.gray850,
              Class.padding([.mobile: [.all: 2]])
              ]),
            HtmlCssSupport.style(lineHeight(0))
          ],
          [
            label(
              [
                `class`([
                  Class.cursor.pointer,
                  Class.flex.flex,
                  Class.flex.items.baseline
                  ])
              ],
              [
                div(
                  [
                    input([
                      checked(subscribeData?.pricing.billing == .monthly),
                      id("monthly"),
                      type(.radio),
                      name("pricing[billing]"),
                      value("monthly"),
                      ])
                  ]
                ),
                div(
                  [
                    `class`([Class.margin([.mobile: [.left: 2]])]),
                  ],
                  [
                    h5(
                      [
                        `class`([
                          Class.pf.type.responsiveTitle6,
                          Class.margin([.mobile: [.all: 0]])
                          ])
                      ],
                      ["Monthly"]
                    ),
                    p(
                      [
                        `class`([
                          Class.padding([.mobile: [.top: 1]]),
                          Class.pf.type.body.small,
                          Class.pf.colors.fg.gray650
                          ])
                      ],
                      [
                        lane == .team
                          ? "$16 per member, per month"
                          : "$18 per month"
                      ]
                    )
                  ]
                )
              ]
            )
          ]
        )
      ]
    )
  ]
}

private func payment(
  lane: Pricing.Lane,
  coupon: Stripe.Coupon?,
  stripeJs: String,
  stripePublishableKey: String
) -> [Node] {
  return [
    gridRow(
      [`class`([moduleRowClass])],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [`class`([moduleTitleColumnClass])],
          [h1([`class`([moduleTitleClass])], ["Payment info"])]
        ),

        label(
          [
            `for`("card"),
            `class`([
              Class.type.nowrap,
              Class.pf.colors.fg.black,
              Class.pf.colors.bg.white,
              Class.pf.type.responsiveTitle6,
            ]),
          ],
          ["Credit or debit card"]
        ),

        gridColumn(
          sizes: [.mobile: 12],
          [
            `class`([
              Class.border.all,
              Class.pf.colors.border.gray850,
              Class.padding([.mobile: [.all: 2]]),
              Class.margin([.mobile: [.top: 1]])
            ]),
            HtmlCssSupport.style(lineHeight(0))
          ],
          [
            div(
              [
                `class`([
                  Class.flex.flex,
                  Class.grid.middle(.mobile)
                ])
              ],
              [
                div([
                  `class`([Class.size.width100pct]),
                  data("stripe-key", stripePublishableKey),
                  id("card-element"),
                ], []),
              ]
            )
          ]
        ),

        gridColumn(
          sizes: [.mobile: 12],
          [],
          [
            div([
              `class`([
                Class.pf.colors.fg.red,
                Class.pf.type.body.small,
              ]),
              id("card-errors"),
            ], []),
            input([
              name("token"),
              `type`(.hidden)
            ]),
            script([src(stripeJs)]),
            script("""
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
    stripe.createToken(
      card, { /*TODO: name: form.stripe_name.value*/ }
    ).then(function(result) {
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
"""),
          ]
        ),
      ]
        + (coupon.map(discount) ?? [])
        + [
          gridColumn(
            sizes: [.mobile: 12],
            [`class`([Class.padding([.mobile: [.top: 3, .bottom: 2]])])],
            [
              p(
                [
                  `class`([
                    Class.pf.type.body.small,
                    Class.pf.colors.fg.gray400
                  ]),
                  id("pricing-preview"),
                ],
                []
              )
            ]
          )
      ]
    )
  ]
}

private func discount(coupon: Stripe.Coupon) -> [Node] {
  return [
    input([
      `class`([Class.display.none]),
      disabled(true),
      name("coupon"),
      placeholder("Coupon Code"),
      type(.hidden),
      value(coupon.id.rawValue)
      ]),
  ]
}

private func total(lane: Pricing.Lane, coupon: Stripe.Coupon?) -> [Node] {
  let discount = coupon?.discount ?? { $0 }
  return [
    gridRow(
      [
        `class`([
          Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]]),
          Class.padding([.mobile: [.top: 3, .bottom: 4], .desktop: [.top: 3, .bottom: 4]]),
          Class.grid.middle(.mobile)
          ])
      ],
      [
        gridColumn(
          sizes: [:],
          [`class`([Class.grid.start(.mobile)])],
          [
            div(
              [
                `class`([
                  Class.flex.flex,
                  Class.flex.align.center,
                  Class.grid.middle(.mobile),
                  ])
              ],
              [
                h3(
                  [
                    `class`([
                      Class.pf.type.responsiveTitle2,
                      Class.type.normal,
                      Class.margin([.mobile: [.topBottom: 0]])
                    ]),
                    id("total"),
                  ],
                  [""]
                ),
                input([
                  name("pricing[quantity]"),
                  `type`(.hidden),
                ]),
                .element(
                  "script",
                  [],
                  [.raw(#"""
function format(money) {
  return "$" + money.toFixed(2).replace(/\.00$/, "")
}
function updateSeats() {
  var teamMembers = document.getElementById("team-members")
  var teamMemberInputs = teamMembers == null ? [] : Array.from(teamMembers.getElementsByTagName("INPUT"))
  for (var idx = 0; idx < teamMemberInputs.length; idx++) {
    teamMemberInputs[idx].name = "teammates[" + idx + "]"
  }
  var seats = teamMembers
    ? teamMembers.childNodes.length + 1
    : 1
  var form = document.getElementById("subscribe-form")
  form["pricing[quantity]"].value = seats
  var monthly = form["pricing[billing]"].value == "monthly"
  var monthlyPrice = (
    monthly
      ? seats * \#(discount(lane == .team ? 16_00 : 18_00)) * 0.01
      : seats * \#(discount(lane == .team ? 12_00 : 14_00)) * 0.01
  )
  document.getElementById("total").textContent = format(
    monthly
      ? monthlyPrice
      : monthlyPrice * 12
  )
  document.getElementById("pricing-preview").innerHTML = (
    "You will be charged <strong>"
      + format(monthlyPrice)
      + " per month</strong>"
      + (monthly ? "" : " times <strong>12 months</strong>")
      + "."
  )
}
window.addEventListener("load", function() {
  updateSeats()
  var form = document.getElementById("subscribe-form")
  form.addEventListener("change", updateSeats)
})
"""#)]),
                span(
                  [
                    `class`([
                      Class.pf.type.body.small,
                      Class.pf.colors.fg.gray400,
                      Class.margin([.mobile: [.left: 1]]),
                      Class.padding([.mobile: [.bottom: 1]])
                      ])
                  ],
                  ["Total"]
                )
              ]
            )
          ]
        ),
        gridColumn(
          sizes: [:],
          [`class`([Class.grid.end(.mobile)])],
          [
            button(
              [
                `class`([
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
              ["Subscribe"]
            )
          ]
        )
      ]
    )
  ]
}

private let moduleTitleClass =
  Class.pf.type.responsiveTitle3
    | Class.margin([.mobile: [.top: 0]])

private let moduleTitleColumnClass =
  Class.padding([.mobile: [.bottom: 1], .desktop: [.bottom: 2]])

private let moduleRowClass =
  Class.margin([.mobile: [.leftRight: 2], .desktop: [.leftRight: 4]])
    | Class.padding([.mobile: [.topBottom: 3]])
    | Class.border.bottom
    | Class.pf.colors.border.gray850
