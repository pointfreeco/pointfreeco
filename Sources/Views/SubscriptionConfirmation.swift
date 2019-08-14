import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tagged

public func subscriptionConfirmation(unit: Prelude.Unit) -> [Node] {
  return header
    + teamMembers()
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
          .raw("You selected the <strong>Team</strong> plan")
        ]
      ),
      gridColumn(
        sizes: [:],
        [
          `class`([Class.grid.end(.mobile)])
        ],
        [
          a(
            [],
            ["Change plan"]
          )
        ]
      )
    ]
  )
]

private func teamMembers() -> [Node] {
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
        teamOwner(),
        teamMemberTemplate(),
        teamMemberTemplate(),
        gridColumn(
          sizes: [.mobile: 12],
          [
            `class`([Class.padding([.mobile: [.top: 3]])])
          ],
          [
            div(
              [],
              [
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

private func teamOwner() -> Node {
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
            src: "",
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
          span(["Andrew Cornett"])
        ]
      )
    ]
  )
}

private func teamMemberTemplate() -> Node {
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
            placeholder("Email address"),
            `class`([Class.size.width100pct]),
            name("teammate[]"),
            style(
              borderWidth(all: 0)
                <> key("outline", "none")
            )
            ])
        ]
      )
    ]
  )
}

private func billingPeriod() -> Node {
  return div([])
}
