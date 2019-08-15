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
  return header
    + teamMembers(currentUser)
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
              `class`([Class.pf.colors.link.gray650]),
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

private func billingPeriod() -> Node {
  return div([])
}
