import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Stripe
import Styleguide
import Tagged

public func subscriptionConfirmation(
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
      header
        + teamMembers(currentUser)
        + billingPeriod()
        + payment(stripeJs: stripeJs, stripePublishableKey: stripePublishableKey)
        + total()
    )
  ]
}

private let header: [Node] = [
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
        ["You selected the ", strong(["Team"]), " plan"]
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

private func teamMembers(_ currentUser: User) -> [Node] {
  return [
    input([
      name("pricing[lane]"),
      type(.hidden),
      value("team"),
    ]),
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
          [teamMemberTemplate(withRemoveButton: false)]
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
                  [teamMemberTemplate(withRemoveButton: true)]
                ),
                a(
                  [
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

private func teamMemberTemplate(withRemoveButton: Bool) -> Node {
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
            )
          ]),
          ] + (withRemoveButton
            ? [
              a([
                `class`([Class.cursor.pointer]),
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

private func billingPeriod() -> [Node] {
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
                    checked(true),
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
                      ["Yearly — 25% off!"]
                    ),
                    p(
                      [
                        `class`([
                          Class.padding([.mobile: [.top: 1]]),
                          Class.pf.type.body.small,
                          Class.pf.colors.fg.gray650
                          ])
                      ],
                      ["$144 per member per year"]
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
                      ["$16 per member, per month"]
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

private func payment(stripeJs: String, stripePublishableKey: String) -> [Node] {
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
          ["Card number"]
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

        gridColumn(
          sizes: [.mobile: 12],
          [`class`([Class.padding([.mobile: [.top: 3, .bottom: 2]])])],
          [
            p(
              [
                `class`([
                  Class.pf.type.body.small,
                  Class.pf.colors.fg.gray400
                  ])
              ],
              [
                "You will be charged ",
                strong(["$14 per member, per month"]),
                " times ",
                strong(["12 months"]),
                "."
              ]
            )
          ]
        )
      ]
    )
  ]
}

private func total() -> [Node] {
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
                      Class.type.normal
                    ]),
                    id("total"),
                  ],
                  [""]
                ),
                input([
                  name("pricing[quantity]"),
                  `type`(.hidden),
                ]),
                script("""
function updateSeats() {
  var teamMembers = document.getElementById("team-members")
  var seats = teamMembers.childNodes.length + 1
  var form = document.getElementById("subscribe-form")
  form["pricing[quantity]"].value = seats
  document.getElementById("total").textContent = "$" + (
    form["pricing[billing]"].value == "monthly"
      ? seats * 16
      : seats * 12 * 12
  )
}
window.addEventListener("load", function() {
  updateSeats()
  var form = document.getElementById("subscribe-form")
  form.addEventListener("change", updateSeats)
})
"""),
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
