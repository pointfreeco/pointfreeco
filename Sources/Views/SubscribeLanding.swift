import Css
import FunctionalCss
import Html
import Models
import PointFreeRouter
import Prelude
import Styleguide
import View
import HtmlCssSupport

public func subscribeLanding(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  return hero(currentUser: currentUser, subscriberState: subscriberState)
    + plansAndPricing
    + whatToExpect
    + faq
    + whatPeopleAreSaying
    + featuredTeams
    + footer(currentUser: currentUser)
}

func ctaColumn(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  guard !subscriberState.isActive else { return [] }

  return [
    gridColumn(
      sizes: [.mobile: 12, .desktop: 4],
      [
        `class`([
          Class.grid.center(.desktop),
          Class.padding([.desktop: [.left: 2]])
          ])
      ],
      [
        div(
          [],
          [
            p(
              [
                `class`([
                  Class.pf.colors.fg.white,
                  Class.padding([.mobile: [.bottom: 2]])
                  ])
              ],
              ["Start with a free episode"]
            ),
            gitHubLink(
              text: "Create your account",
              type: .white,
              // TODO: redirect back to home?
              href: path(to: .login(redirect: url(to: .subscribeLanding)))
            )
          ]
        )
      ]
    )
  ]
}

private func titleColumn(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  let isTwoColumnHero = !subscriberState.isActive
  let titleColumnCount = isTwoColumnHero ? 8 : 12

  return [
    gridColumn(
      sizes: [.mobile: 12, .desktop: titleColumnCount],
      [
        `class`([
          Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 0, .right: 2]]),
          isTwoColumnHero ? darkRightBorder: .star
          ]),
      ],
      [
        h1(
          [
            `class`([
              Class.pf.type.responsiveTitle2,
              Class.pf.colors.fg.white
              ]),
            style(lineHeight(1.2))
          ],
          [.raw("Explore the wonderful world of&nbsp;functional programming in Swift.")]
        )
      ]
    )
  ]
}

private func hero(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  return [
    div(
      [
        `class`([
          Class.pf.colors.bg.black,
          Class.padding([.mobile: [.leftRight: 3, .topBottom: 4], .desktop: [.all: 5]])
          ]),
        style(
          // TODO: move to nav?
          key("border-top", "1px solid #333")
        )
      ],
      [
        gridRow(
          [
            `class`([Class.grid.middle(.desktop)])
          ],
          titleColumn(currentUser: currentUser, subscriberState: subscriberState)
            + ctaColumn(currentUser: currentUser, subscriberState: subscriberState)
        )
      ]
    )
  ]
}

private let plansAndPricing = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["Plans and pricing"]
      )
    ]
  )
]

private let whatToExpect = [
  gridRow(
    [
      `class`([
        Class.padding([.mobile: [.leftRight: 3, .topBottom: 3], .desktop: [.all: 4]])
        ]),
      style(backgroundColor(.other("#fafafa")))
    ],
    [
      gridColumn(
        sizes: [.mobile: 12],
        [
          `class`([
            Class.grid.center(.desktop),
            Class.padding([.desktop: [.bottom: 3]])
            ])
        ],
        [
          h3(
            [`class`([Class.pf.type.responsiveTitle3])],
            ["What to expect"]
          )
        ]
      ),
      gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        [
          `class`([
            Class.grid.center(.desktop),
            Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
            Class.margin([.mobile: [.bottom: 1], .desktop: [.bottom: 0]]),
            lightBottomBorder,
            lightRightBorder
            ]),
        ],
        [whatToExpectColumn(item: .newContent)]
      ),
      gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        [
          `class`([
            Class.grid.center(.desktop),
            Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
            Class.margin([.mobile: [.bottom: 1], .desktop: [.bottom: 0]]),
            lightBottomBorder
            ])
        ],
        [whatToExpectColumn(item: .topics)]
      ),
      gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        [
          `class`([
            Class.grid.center(.desktop),
            Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]]),
            Class.margin([.mobile: [.bottom: 1], .desktop: [.bottom: 0]]),
            lightRightBorder
            ])
        ],
        [whatToExpectColumn(item: .playgrounds)]
      ),
      gridColumn(
        sizes: [.mobile: 12, .desktop: 6],
        [`class`([Class.grid.center(.desktop)])],
        [whatToExpectColumn(item: .transcripts)]
      )
    ]
  )
]

private func whatToExpectColumn(item: WhatToExpectItem) -> Node {
  return div(
    [`class`([Class.padding([.desktop: [.all: 3]])])],
    [
      img(
        src: item.imageSrc,
        alt: "",
        [
          `class`([
            Class.layout.fit, Class.margin([.mobile: [.bottom: 2]]),
            Class.pf.colors.bg.white
            ])
        ]
      ),
      h4(
        [`class`([Class.pf.type.responsiveTitle5])],
        [.text(item.title)]
      ),
      p(
        [`class`([Class.pf.colors.fg.gray400])],
        [.text(item.description)]
      )
    ]
  )
}

private let faq = [
  gridRow(
    [
      `class`([
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 4]]),
        Class.grid.around(.mobile)
        ])
    ],
    [
      gridColumn(
        sizes: [.mobile: 12, .desktop: 8],
        [
          div([
            h3(
              [
                `class`([
                  Class.pf.type.responsiveTitle3,
                  Class.type.align.center
                  ]),
              ],
              ["FAQ"]
            )
            ]
            + faqItems
          )
        ]
      )
    ]
  )
]

private let faqItems = Faq.allFaqs.flatMap { faq in
  [
    p(
      [
        `class`([
          Class.padding([.mobile: [.top: 3]]),
          Class.type.bold,
          Class.pf.colors.fg.black
          ])
      ],
      [.text(faq.question)]
    ),
    p(
      [`class`([Class.pf.colors.fg.gray400])],
      [.text(faq.answer)]
    )
  ]
}

private let whatPeopleAreSaying = [
  div(
    [],
    [
      h3(
        [`class`([Class.pf.type.responsiveTitle3])],
        ["What people are saying"]
      )
    ]
  )
]

private let featuredTeams = [
  gridRow(
    [
      `class`([
        Class.pf.colors.bg.gray900,
        Class.padding([.mobile: [.all: 3], .desktop: [.all: 3]]),
        Class.grid.middle(.mobile),
        Class.grid.center(.mobile)
        ])
    ],
    [
      gridColumn(
        sizes: [.mobile: 12, .desktop: 12],
        [`class`([Class.padding([.mobile: [.bottom: 2]])])],
        [
          h6(
            [
              `class`([
                Class.pf.colors.fg.gray400,
                Class.pf.type.responsiveTitle7,
                Class.type.align.center
                ]),
            ],
            ["Featured Teams"]
          )
        ]
      ),

      gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        [`class`([Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]])])],
        [img(base64: nytLogoSvg, type: .image(.svg), alt: "New York Times", [])]
      ),
      gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        [`class`([Class.padding([.mobile: [.bottom: 3], .desktop: [.bottom: 0]])])],
        [img(base64: spotifyLogoSvg, type: .image(.svg), alt: "Spotify", [])]
      ),
      gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        [img(base64: venmoLogoSvg, type: .image(.svg), alt: "Venmo", [])]
      ),
      gridColumn(
        sizes: [.mobile: 6, .desktop: 2],
        [img(base64: atlassianLogoSvg, type: .image(.svg), alt: "Atlassian", [])]
      ),
    ]
  )
]

private func footer(currentUser: User?) -> [Node] {
  guard currentUser == nil else { return [] }

  return [
    div(
      [
        `class`([
          Class.pf.colors.bg.gray150,
          Class.padding([.mobile: [.leftRight: 2, .topBottom: 4], .desktop: [.all: 5]]),
          Class.type.align.center
          ]),
      ],
      [
        h3(
          [
            `class`([
              Class.pf.type.responsiveTitle3,
              Class.pf.colors.fg.white
              ])
          ],
          ["Get started with our free plan"]
        ),
        p(
          [
            `class`([
              Class.pf.colors.fg.white,
              Class.padding([.mobile: [.bottom: 3]])
              ])
          ],
          [.raw("Includes a free episode of your choice, plus weekly<br>updates from our newsletter.")]
        ),
        gitHubLink(
          text: "Create your account",
          type: .white,
          // TODO: redirect back to home?
          href: path(to: .login(redirect: url(to: .subscribeLanding)))
        )
      ]
    )
  ]
}

public let extraSubscriptionLandingStyles =
  Breakpoint.desktop.query(only: screen) {
    darkRightBorder % key("border-right", "1px solid #333")
      <> lightRightBorder % key("border-right", "1px solid #e8e8e8")
      <> lightBottomBorder % key("border-bottom", "1px solid #e8e8e8")
}

private let darkRightBorder = CssSelector.class("dark-right-border-d")
private let lightRightBorder = CssSelector.class("light-right-border-d")
private let lightBottomBorder = CssSelector.class("light-bottom-border-d")

private struct Faq {
  let question: String
  let answer: String

  static let allFaqs = [
    Faq(
      question: "Do you offer student discounts?",
      answer: """
We do! If you email us proof of your student status (e.g. scan of ID card) we will give you a 50% discount
off of the individual plan.
"""
    ),
    Faq(
      question: "Can I change my plan?",
      answer: """
Yes, absolutely. Simply click on the “Organization Settings” link in the web app and navigate to the
“Billing” section. You’ll be able to change plans there.
"""
    ),
    Faq(
      question: "What happens when I cancel?",
      answer: """
All plans can be canceled any time. Your plan features remain available through the end of your billing cycle.
"""
    ),
  ]
}

private struct WhatToExpectItem {
  let imageSrc: String
  let title: String
  let description: String

  static let newContent = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/regular-updates.jpg",
    title: "New content every week",
    description: """
Every week, we’ll dissect some of the most important topics in functional programming, and deliver them
straight to your inbox.
"""
  )

  static let topics = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/episode-topics.jpg",
    title: "Wide variety of topics",
    description: """
We cover both abstract ideas and practical concepts you can start using in your code base immediately.
"""
  )

  static let playgrounds = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/download-playgrounds.jpg",
    title: "Playground downloads",
    description: """
Download a fully-functioning Swift playground from the episode so you can experiment with the concepts
discussed.
"""
  )

  static let transcripts = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/video-transcription.jpg",
    title: "Video transcripts",
    description: """
We transcribe each video by hand so you can search and reference easily. Click on a timestamp to jump
directly to the video.
"""
  )
}
