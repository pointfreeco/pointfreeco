import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tagged

public func subscriptionConfirmation(_ currentUser: User) -> [Node] {
  return [
    div(
      [style(maxWidth(.px(1080)) <> margin(leftRight: .auto))],
      header
        + teamMembers(currentUser)
        + billingPeriod()
        + payment()
        + total()
    )
  ]
}

private let header: [Node] = [
  gridRow(
    [
      `class`([
        Class.margin([.desktop: [.leftRight: 4]]),
        Class.padding([.desktop: [.top: 4, .bottom: 3]]),
        Class.border.bottom,
        Class.pf.colors.border.gray850
        ])
    ],
    [
      gridColumn(
        sizes: [.mobile: 12],
        [],
        [
          h1([`class`([Class.pf.type.responsiveTitle2])], ["Subscribe"])
        ]
      ),
      gridColumn(
        sizes: [:],
        [
          `class`([Class.grid.start(.mobile)])
        ],
        [
          "You selected the ", strong(["Team"]), " plan"
        ]
      ),
      gridColumn(
        sizes: [:],
        [
          `class`([Class.grid.end(.mobile)])
        ],
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
    gridRow(
      [
        `class`([
          Class.margin([.desktop: [.leftRight: 4]]),
          Class.padding([.desktop: [.top: 3, .bottom: 3]]),
          Class.border.bottom,
          Class.pf.colors.border.gray850
          ])
      ],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [`class`([Class.padding([.mobile: [.bottom: 2]])])],
          [h1([`class`([Class.pf.type.responsiveTitle3])], ["Team members"])]
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
            type(.text),
            placeholder("blob@pointfree.co"),
            `class`([Class.size.width100pct]),
            name("teammate[]"),
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
      [
        `class`([
          Class.margin([.desktop: [.leftRight: 4]]),
          Class.padding([.desktop: [.top: 3, .bottom: 3]]),
          Class.border.bottom,
          Class.pf.colors.border.gray850
          ])
      ],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [`class`([Class.padding([.mobile: [.bottom: 2]])])],
          [h1([`class`([Class.pf.type.responsiveTitle3])], ["Billing interval"])]
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
                    id("foo-bar-yearly"),
                    type(.radio),
                    name("billing-interval")
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
                      id("foo-bar-monthly"),
                      type(.radio),
                      name("billing-interval")
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

private func payment() -> [Node] {
  return [
    gridRow(
      [
        `class`([
          Class.margin([.desktop: [.leftRight: 4]]),
          Class.padding([.desktop: [.top: 3, .bottom: 3]]),
          Class.border.bottom,
          Class.pf.colors.border.gray850
          ])
      ],
      [
        gridColumn(
          sizes: [.mobile: 12],
          [`class`([Class.padding([.mobile: [.bottom: 2]])])],
          [h1([`class`([Class.pf.type.responsiveTitle3])], ["Payment info"])]
        ),

        gridColumn(
          sizes: [.mobile: 12],
          [`class`([Class.padding([.mobile: [.bottom: 2]])])],
          [
            p(
              [
                `class`([
                  Class.pf.type.body.small,
                  Class.pf.colors.fg.gray400
                  ])
              ],
              [.raw("""
You will be charged <strong>$14 per member per month</strong>, times <strong>12 months</strong>.
""")]
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
          Class.margin([.desktop: [.leftRight: 4, .topBottom: 3]]),
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
                  Class.grid.middle(.mobile)
                  ])
              ],
              [
                h3(
                  [
                    `class`([
                      Class.pf.type.responsiveTitle3,
                      Class.type.normal
                      ])
                  ],
                  ["$336"]
                ),
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
                  Class.typeScale([.mobile: .r1_25, .desktop: .r1]),
                  Class.padding([.mobile: [.topBottom: 2, .leftRight: 2]]),
                  Class.type.align.center,
                  Class.pf.colors.bg.black,
                  Class.pf.colors.fg.white,
                  Class.pf.colors.link.white,
                  ])
              ],
              [.raw("Subscribe")]
            )
          ]
        )
      ]
    )
  ]
}
