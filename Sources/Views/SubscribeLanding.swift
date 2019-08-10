import Css
import FunctionalCss
import Html
import HtmlCssSupport
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

private let baseCtaButtonClass =
  Class.display.block
    | Class.size.width100pct
    | Class.pf.type.responsiveTitle6
    | Class.padding([.mobile: [.topBottom: 1]])
    | Class.type.align.center

private let choosePlanButtonClasses =
  baseCtaButtonClass
    | Class.pf.colors.bg.black
    | Class.pf.colors.fg.white
    | Class.pf.colors.link.white

private let contactusButtonClasses =
  baseCtaButtonClass
    | Class.pf.colors.bg.white
    | Class.pf.colors.fg.black
    | Class.pf.colors.link.black
    | Class.border.all
    | Class.pf.colors.border.gray800

private let plansAndPricing = [
  gridRow(
    [
      `class`([
        Class.padding([.mobile: [.leftRight: 2, .top: 2], .desktop: [.leftRight: 4, .top: 4]]),
        Class.grid.between(.desktop)
        ]),
    ],
    [
      gridColumn(
        sizes: [.mobile: 12],
        [
          `class`([
            Class.grid.center(.desktop),
            Class.padding([.desktop: [.bottom: 2]])
            ])
        ],
        [
          h3(
            [`class`([Class.pf.type.responsiveTitle3])],
            ["Plans and pricing"]
          )
        ]
      )
    ]
  ),
  ul(
    [
      `class`([
        Class.margin([.mobile: [.all: 0]]),
        Class.padding([.mobile: [.all: 0], .desktop: [.leftRight: 2, .topBottom: 0]]),
        Class.type.list.styleNone,
        Class.flex.wrap,
        Class.flex.flex
        ]),
    ],
    [
      pricingPlan(.free),
      pricingPlan(.individual),
      pricingPlan(.team),
      pricingPlan(.enterprise),
    ]
  ),
  gridRow(
    [
      `class`([
        Class.padding([.mobile: [.leftRight: 2], .desktop: [.leftRight: 5]]),
        ]),
    ],
    [
      gridColumn(
        sizes: [.mobile: 12],
        [
          `class`([
            Class.grid.center(.desktop),
            Class.padding([.mobile: [.top: 2, .bottom: 3, .leftRight: 2], .desktop: [.leftRight: 5, .bottom: 4]])
            ])
        ],
        [
          p(
            [
              `class`([
                Class.pf.type.body.small,
                Class.pf.colors.fg.gray400
                ])
            ],
            [.raw("""
Prices shown with annual billing. When billed month to month, the Personal plan is $18, and the Team plan is $16 per member per month.
""")]
          )
        ]
      )
    ]
  ),
]

private func planCost(_ cost: PricingPlan.Cost) -> Node {
  return gridRow(
    [
      `class`([
        Class.grid.start(.mobile),
        Class.grid.middle(.mobile)
        ]),
    ],
    [
      gridColumn(
        sizes: [:],
        [
          `class`([
            Class.padding([.mobile: [.right: 2]])
            ]),
          style(flex(grow: 0, shrink: nil, basis: nil))
        ],
        [
          h3(
            [
              `class`([
                Class.pf.colors.fg.black,
                Class.typeScale([.mobile: .r2, .desktop: .r2]),
                Class.type.light
                ])
            ],
            [.text(cost.value)]
          )
        ]
      ),
      gridColumn(
        sizes: [:],
        [],
        [
          p(
            [
              `class`([
                Class.pf.type.body.small,
                Class.typeScale([.mobile: .r0_875, .desktop: .r0_75]),
                Class.type.lineHeight(1)
                ])
            ],
            [.raw(cost.title ?? "")]
          )
        ]
      ),
    ]
  )
}

private func pricingPlan(_ plan: PricingPlan) -> ChildOf<Tag.Ul> {
  let cost = plan.cost.map(planCost) ?? div([])

  let ctaButton = a(
    [
      href("#"),
      `class`([
        Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
        plan.cost == nil ? contactusButtonClasses : choosePlanButtonClasses
        ])
    ],
    [
      plan.cost == nil ? "Contact Us" : "Choose plan"
    ]
  )

  return li(
    [
      `class`([
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 1]]),
        Class.margin([.mobile: [.all: 0]]),
        Class.flex.flex,
        planItem,
        ])
    ],
    [
      div(
        [
          `class`([
            Class.pf.colors.bg.gray900,
            Class.flex.column,
            Class.padding([.mobile: [.all: 2]]),
            Class.size.width100pct,
            Class.flex.flex,
            ]),
        ],
        [
          h4(
            [`class`([Class.pf.type.responsiveTitle4])],
            [.text(plan.title)]
          ),
          cost,
          ul(
            [
              `class`([
                Class.type.list.styleNone,
                Class.padding([.mobile: [.all: 0]]),
                Class.pf.colors.fg.gray400,
                Class.pf.type.body.small,
                ]),
              style(flex(grow: 1, shrink: 0, basis: .auto))
            ],
            plan.features.map { feature in
              li(
                [`class`([Class.padding([.mobile: [.top: 1]])])],
                [.text(feature)]
              )
            }
          ),
          ctaButton
        ]
      )
    ]
  )
}

private struct PricingPlan {
  let cost: Cost?
  let features: [String]
  let title: String

  struct Cost {
    let title: String?
    let value: String
  }

  static let free = PricingPlan(
    cost: Cost(title: nil, value: "$0"),
    features: [
      "Weekly newsletter access",
      "9 episodes with transcripts",
      "1 subscriber-only episode of your choice",
      "Download all Swift playgrounds"
    ],
    title: "Free"
  )

  static let individual = PricingPlan(
    cost: Cost(title: "per month", value: "$17"),
    features: [
      "All episodes with transcripts",
      "Download all Swift playgrounds",
      "RSS feed for viewing in podcast apps",
      "Billing changes automatically pro-rated"
    ],
    title: "Personal"
  )

  static let team = PricingPlan(
    cost: Cost(title: "per member, per&nbsp;month", value: "$16"),
    features: [
      "Two or more members",
      "All personal plan features",
      "(*) Free account for team administrators",
      "Add, remove, or reassign members"
    ],
    title: "Team"
  )

  static let enterprise = PricingPlan(
    cost: nil,
    features: [
      "Unlimited members",
      "All team plan features",
      "(*) Multiple team administrators",
      "Invoiced billing"
    ],
    title: "Enterprise"
  )
}

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
  gridRow(
    [
      `class`([
        Class.grid.between(.desktop)
        ]),
    ],
    [
      gridColumn(
        sizes: [.mobile: 12],
        [
          `class`([
            Class.padding([.mobile: [.leftRight: 2, .top: 2], .desktop: [.leftRight: 4, .top: 4]]),
            Class.grid.center(.desktop)
            ])
        ],
        [
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
      ),
      div(
        [
          `class`([
            Class.flex.flex,
            Class.flex.none,
            Class.size.width100pct,
            Class.margin([.mobile: [.bottom: 2]]),
            Class.layout.overflowAuto(.x)
            ]),
          style(
            height(.px(320))
            <> key("-webkit-overflow-scrolling", "touch")
          )
        ],
        [Testimonial.romain, .romain, .romain, .romain, .romain, .romain, .romain, .romain].map { testimonial in
          div(
            [
              `class`([
                Class.flex.column,
                Class.flex.flex,
                Class.pf.colors.bg.gray900,
                Class.padding([.mobile: [.all: 3]]),
                Class.margin([.mobile: [.leftRight: 2]])
                ]),
              style(
                flex(grow: 0, shrink: 0, basis: .auto)
                <> width(.px(260))
                <> height(.px(340))
              )
            ],
            [
              a(
                [
                  href(testimonial.tweetUrl),
                  `class`([
                    Class.pf.colors.fg.black,
                    Class.pf.type.body.leading
                    ]),
                  style(flex(grow: 1, shrink: 0, basis: .auto))
                ],
                [.text("“\(testimonial.quote)”")]
              ),
              a(
                [
                  href("https://www.twitter.com/\(testimonial.twitterHandle)"),
                  `class`([
                    Class.pf.colors.fg.black,
                    Class.pf.type.body.leading,

                    ]),
                ],
                [
                  twitterIconImg(fill: "1DA1F3"),
                  span(
                    [
                      `class`([Class.type.medium]),
                      style(margin(left: .px(3)))
                    ],
                    [.text(testimonial.subscriber ?? "@\(testimonial.twitterHandle)")]
                  )
                ]
              )
            ]
          )
        }
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
    extraSubscriptionLandingDesktopStyles
    }
    <> Breakpoint.mobile.querySelfAndBigger(only: screen) {
      planItem % width(.pct(100))
}

private let extraSubscriptionLandingDesktopStyles =
  darkRightBorder % key("border-right", "1px solid #333")
    <> lightRightBorder % key("border-right", "1px solid #e8e8e8")
    <> lightBottomBorder % key("border-bottom", "1px solid #e8e8e8")
    <> planItem % width(.pct(25))

private let darkRightBorder = CssSelector.class("dark-right-border-d")
private let lightRightBorder = CssSelector.class("light-right-border-d")
private let lightBottomBorder = CssSelector.class("light-bottom-border-d")
private let planItem = CssSelector.class("plan-item")

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

private struct Testimonial {
  let quote: String
  let subscriber: String?
  let tweetUrl: String
  let twitterHandle: String

  static let romain = Testimonial(
    quote: """
There clearly was a before and an after @pointfreeco for me. I've always been an FP enthusiast intimidated by the F-word, but they made that accessible to the rest of us. Highly recommended!
""",
    subscriber: "Romain Pouclet",
    tweetUrl: "https://twitter.com/Palleas/status/1023976413429260288",
    twitterHandle: "Palleas"
  )
}
