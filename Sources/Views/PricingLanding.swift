import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tagged
import View
import HtmlCssSupport

public typealias FreeEpisodeCount = Tagged<((), freeEpisodeCount: ()), Int>
public typealias AllEpisodeCount = Tagged<((), allEpisodeCount: ()), Int>
public typealias EpisodeHourCount = Tagged<((), episodeHourCount: ()), Int>

public func pricingLanding(
  allEpisodeCount: AllEpisodeCount,
  currentUser: User?,
  episodeHourCount: EpisodeHourCount,
  freeEpisodeCount: FreeEpisodeCount,
  subscriberState: SubscriberState
  ) -> [Node] {

  return hero(currentUser: currentUser, subscriberState: subscriberState)
    + plansAndPricing(
      allEpisodeCount: allEpisodeCount,
      episodeHourCount: episodeHourCount,
      freeEpisodeCount: freeEpisodeCount,
      subscriberState: subscriberState
    )
    + whatToExpect
    + faq
    + whatPeopleAreSaying
    + featuredTeams
    + footer(allEpisodeCount: allEpisodeCount, currentUser: currentUser, subscriberState: subscriberState)
}

func ctaColumn(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  guard currentUser == nil || subscriberState.isActive else { return [] }

  let title = subscriberState.isActive
    ? "You‘re already a subscriber!"
    : "Start with a free episode"

  let ctaButton = subscriberState.isActive
    ? a(
      [
        href(path(to: .account(.index))),
        `class`([Class.pf.components.button(color: .white)])
      ],
      ["Manage your account"]
    )
    : gitHubLink(
      text: "Create your account",
      type: .white,
      // TODO: redirect back to home?
      href: path(to: .login(redirect: url(to: .pricingLanding)))
  )

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
              [.text(title)]
            ),
            ctaButton
          ]
        )
      ]
    )
  ]
}

private func titleColumn(currentUser: User?, subscriberState: SubscriberState) -> [Node] {
  let isTwoColumnHero = currentUser == nil || subscriberState.isActive
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
          Class.border.top,
          ]),
        // TODO: move to nav?
        style(key("border-top-color", "#333"))
      ],
      [
        gridRow(
          [
            `class`([
              Class.grid.middle(.desktop),
              Class.padding([.mobile: [.leftRight: 3, .topBottom: 4], .desktop: [.all: 5]])
              ]),
            style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
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
    | Class.type.bold
    | Class.typeScale([.mobile: .r1_25, .desktop: .r1])
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

private func plansAndPricing(
  allEpisodeCount: AllEpisodeCount,
  episodeHourCount: EpisodeHourCount,
  freeEpisodeCount: FreeEpisodeCount,
  subscriberState: SubscriberState
  ) -> [Node] {
  return [
    gridRow(
      [
        `class`([
          Class.padding([.mobile: [.leftRight: 2, .top: 3], .desktop: [.leftRight: 4, .top: 4]]),
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
              [
                id("plans-and-pricing"),
                `class`([Class.pf.type.responsiveTitle2])
              ],
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
        style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
      ],
      [
        pricingPlan(
          subscriberState: subscriberState,
          plan: .free(freeEpisodeCount: freeEpisodeCount)
        ),
        pricingPlan(
          subscriberState: subscriberState,
          plan: .personal(allEpisodeCount: allEpisodeCount, episodeHourCount: episodeHourCount)
        ),
        pricingPlan(
          subscriberState: subscriberState,
          plan: .team
        ),
        pricingPlan(
          subscriberState: subscriberState,
          plan: .enterprise
        ),
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
              Class.padding([.mobile: [.top: 2, .bottom: 3, .leftRight: 2], .desktop: [.bottom: 4]])
              ])
          ],
          [
            p(
              [
                `class`([
                  Class.pf.type.body.regular,
                  Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
                  Class.pf.colors.fg.gray400
                  ]),
                style(maxWidth(.px(480)) <> margin(leftRight: .auto))
              ],
              [
                "Prices shown with annual billing. When billed month to month, the ",
                strong(["Personal"]),
                " plan is $18, and the ",
                strong(["Team"]),
                " plan is $16 per member per month."
              ]
            )
          ]
        )
      ]
    ),
  ]
}

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

private func pricingPlan(subscriberState: SubscriberState, plan: PricingPlan) -> ChildOf<Tag.Ul> {
  let cost = plan.cost.map(planCost) ?? div([])

  let ctaButton = subscriberState.isActive
    ? div([])
    : a(
    [
      plan.lane
        .map { href(url(to: .subscribeConfirmation($0))) }
        ?? (
          plan.cost == nil
            ? mailto("support@pointfree.co")
            : href(url(to: .account(.index)))
      ),
      `class`([
        Class.margin([.mobile: [.top: 2], .desktop: [.top: 3]]),
        plan.cost == nil ? contactusButtonClasses : choosePlanButtonClasses
        ])
    ],
      [plan.cost == nil ? "Contact Us" : "Choose plan"]
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
                Class.pf.type.body.regular,
                Class.typeScale([.mobile: .r1, .desktop: .r0_875]),
                Class.pf.colors.fg.gray400
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

private let whatToExpect = [
  div(
    [style(backgroundColor(.other("#fafafa")))],
    [
      gridRow(
        [
          `class`([
            Class.padding([.mobile: [.leftRight: 2, .topBottom: 3], .desktop: [.all: 4]])
            ]),
          style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
        ],
        [
          gridColumn(
            sizes: [.mobile: 12],
            [
              `class`([
                Class.grid.center(.desktop),
                Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 3]])
                ])
            ],
            [
              h3(
                [
                  id("what-to-expect"),
                  `class`([Class.pf.type.responsiveTitle2])
                ],
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
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 4]])
        ]),
      style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto))
    ],
    [
      gridColumn(
        sizes: [.mobile: 12, .desktop: 8],
        [
          style(margin(leftRight: .auto))
        ],
        [
          div([
            h3(
              [
                id("faq"),
                `class`([
                  Class.pf.type.responsiveTitle2,
                  Class.grid.center(.desktop),
                  Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 3]])
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
          Class.type.bold,
          Class.pf.colors.fg.black
          ])
      ],
      [.text(faq.question)]
    ),
    p(
      [
        `class`([
          Class.pf.colors.fg.gray400,
          Class.padding([.mobile: [.bottom: 2]]),
          ])
      ],
      [.raw(faq.answer)]
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
            Class.padding([.mobile: [.leftRight: 2, .top: 0, .bottom: 3], .desktop: [.leftRight: 4, .top: 0, .bottom: 3]]),
            Class.grid.center(.desktop),
            ]),
        ],
        [
          div(
            [
              `class`([Class.border.top, Class.padding([.mobile: [.top: 3], .desktop: [.top: 4]])]),
              style(borderColor(top: Colors.gray850))
            ],
            [
              h3(
                [
                  id("what-people-are-saying"),
                  `class`([Class.pf.type.responsiveTitle2])
                ],
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
            Class.margin([.mobile: [.bottom: 4]]),
            Class.layout.overflowAuto(.x),
            testimonialContainer
            ]),
        ],
        Testimonial.all.map { testimonial in
          div(
            [
              `class`([
                Class.flex.column,
                Class.flex.flex,
                Class.pf.colors.bg.gray900,
                Class.padding([.mobile: [.all: 3]]),
                Class.margin([.mobile: [.leftRight: 2]]),
                testimonialItem
                ]),
            ],
            [
              a(
                [
                  href(testimonial.tweetUrl),
                  target(.blank),
                  rel(.init(rawValue: "noopener noreferrer")),
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
        Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]),
        Class.grid.middle(.mobile),
        Class.grid.center(.mobile)
        ])
    ],
    [
      gridColumn(
        sizes: [.mobile: 12, .desktop: 12],
        [`class`([Class.padding([.mobile: [.bottom: 3]])])],
        [
          h6(
            [
              id("featured-teams"),
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

private func footer(
  allEpisodeCount: AllEpisodeCount,
  currentUser: User?,
  subscriberState: SubscriberState
  ) -> [Node] {

  guard !subscriberState.isActive else { return [] }

  let title = currentUser == nil
    ? "Get started with our Free plan"
    : "Get started with our Personal plan"
  let subtitle = currentUser == nil

    ? "Includes a free episode of your choice, plus weekly<br>updates from our newsletter."
    : "Access all \(allEpisodeCount.rawValue) episodes on Point-Free today!"

  let ctaButton = currentUser == nil
    ? gitHubLink(
      text: "Create your account",
      type: .white,
      // TODO: redirect back to home?
      href: path(to: .login(redirect: url(to: .pricingLanding)))
      )
    : a(
      [
        href(path(to: .subscribeConfirmation(.personal))),
        `class`([Class.pf.components.button(color: .white)])
      ],
      ["Subscribe"]
  )

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
          [.text(title)]
        ),
        p(
          [
            `class`([
              Class.pf.colors.fg.white,
              Class.padding([.mobile: [.bottom: 3]])
              ])
          ],
          [.raw(subtitle)]
        ),
        ctaButton
      ]
    )
  ]
}

private struct PricingPlan {
  let cost: Cost?
  let lane: Pricing.Lane?
  let features: [String]
  let title: String

  struct Cost {
    let title: String?
    let value: String
  }

  static func free(freeEpisodeCount: FreeEpisodeCount) -> PricingPlan {
    return PricingPlan(
      cost: Cost(title: nil, value: "$0"),
      lane: nil,
      features: [
        "Weekly newsletter access",
        "\(freeEpisodeCount.rawValue) free episodes with transcripts",
        "1 free credit to redeem any subscriber-only episode",
        "Download all episode playgrounds"
      ],
      title: "Free"
    )
  }

  static func personal(
    allEpisodeCount: AllEpisodeCount,
    episodeHourCount: EpisodeHourCount
    ) -> PricingPlan {
    return PricingPlan(
      cost: Cost(title: "per&nbsp;month, billed&nbsp;annually", value: "$14"),
      lane: .personal,
      features: [
        "All \(allEpisodeCount.rawValue) episodes with transcripts",
        "Over \(episodeHourCount.rawValue) hours of video",
        "Private RSS feed for viewing in podcast apps",
        "Download all episode playgrounds",
      ],
      title: "Personal"
    )
  }

  static let team = PricingPlan(
    cost: Cost(title: "per&nbsp;member, per&nbsp;month, billed&nbsp;annually", value: "$12"),
    lane: .team,
    features: [
      "All personal plan features",
      "For teams of 2 or more",
      "Add teammates at any time with pro-rated billing",
      "Remove and reassign teammates at any time"
    ],
    title: "Team"
  )

  static let enterprise = PricingPlan(
    cost: nil,
    lane: nil,
    features: [
      "For large teams",
      "Unlimited, company-wide access to all content",
      "Hassle-free team management",
      "Custom sign up landing page for your company",
      "Invoiced billing"
    ],
    title: "Enterprise"
  )
}

private struct Faq {
  let question: String
  let answer: String

  static let allFaqs = [
    Faq(
      question: "Do you offer student discounts?",
      answer: """
We do! If you <a href="mailto:support@pointfree.co?subject=Student%20Discount">email us</a> proof of your
student status (e.g. scan of ID card) we will give you a 50% discount off of the Personal plan.
"""
    ),
    Faq(
      question: "Can I upgrade my subscription from monthly to yearly?",
      answer: """
Yes, you can upgrade at any time. You will be charged immediately with a pro-rated amount based on how much
time you have left in your current billing period.
"""),
    Faq(
      question: "How do team subscriptions work?",
      answer: """
A team subscription consists of a number of seats that you pay for, and those seats can be added, removed
and reassigned at any time. Colleagues are invited to your team over email.
"""),
  ]
}

private struct WhatToExpectItem {
  let imageSrc: String
  let title: String
  let description: String

  static let newContent = WhatToExpectItem(
    imageSrc: "https://d3rccdn33rt8ze.cloudfront.net/pricing/regular-updates.jpg",
    title: "New content regularly",
    description: """
We dissect some of the most important topics in functional programming frequently, and deliver them straight
to your inbox.
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
directly to that point in the video.
"""
  )
}

private struct Testimonial {
  let quote: String
  let subscriber: String?
  let tweetUrl: String
  let twitterHandle: String

  static let all: [Testimonial] = [
    Testimonial(
      quote: """
There clearly was a before and an after @pointfreeco for me. I've always been an FP enthusiast intimidated by the F-word, but they made that accessible to the rest of us. Highly recommended!
""",
      subscriber: "Romain Pouclet",
      tweetUrl: "https://twitter.com/Palleas/status/1023976413429260288",
      twitterHandle: "Palleas"
    ),

    Testimonial(
      quote: """
After diving into @pointfreeco series reading Real World Haskell doesn’t seem all that intimidating after all. Major takeaway: the lesser is word “monad” is mentioned the better😅
""",
      subscriber: "Ilya",
      tweetUrl: "https://twitter.com/rehsals/status/1144282266367070209",
      twitterHandle: "rehsals"
    ),

    Testimonial(
      quote: """
So many concepts presented at #WWDC19  reminded me of @pointfreeco video series. 👏👏 So happy I watched it before coming to San Jose.
""",
      subscriber: "Oscar Alvarez",
      tweetUrl: "https://twitter.com/iojcar/status/1136719341376790528",
      twitterHandle: "iOjCaR"
    ),

    Testimonial(
      quote: """
@pointfreeco Talk about being ahead of the curve guys… DSLs, Playground Driven Dev, FRP. Great job. I’m sure you inspired many Apple devs. We know who to look to for where to focus next!
""",
      subscriber: "Sam Rayner",
      tweetUrl: "https://twitter.com/samrayner/status/1136634106618568704",
      twitterHandle: "samrayner"
    ),

    Testimonial(
      quote: """
In February this year I bought the annual subscription pointfree.co and after I watched all videos and played with the sample code and libraries github.com/pointfreeco. I can say it was the best money I spent in the last 12 months.
""",
      subscriber: "Luca Ceppelli",
      tweetUrl: "https://twitter.com/lucaceppelli/status/1136290297242165249",
      twitterHandle: "lucaceppelli"
    ),

    Testimonial(
      quote: """
I've just subscribed to @pointfreeco for a year. I feel their content pushes the boundary of my knowledge, and it's fun to watch!
""",
      subscriber: "Ferran Pujol Camins",
      tweetUrl: "https://twitter.com/ferranpujolca/status/1130908056169136130",
      twitterHandle: "ferranpujolca"
    ),

    Testimonial(
      quote: """
Every episode has been amazing on Pointfree, yet somehow, you've managed to make these Parser combinator episodes even better!!! ⭐️⭐️⭐️⭐️⭐️
""",
      subscriber: "Mike Abidakun",
      tweetUrl: "https://twitter.com/mabidakun/status/1129050657783263232",
      twitterHandle: "mabidakun"
    ),

    Testimonial(
      quote: """
We have this thing called WWTV at #PlanGrid where we mostly just listen to @mbrandonw and @stephencelis talk about functions.
""",
      subscriber: "Arjun Nayini",
      tweetUrl: "https://twitter.com/anayini/status/1129104381566001152",
      twitterHandle: "anayini"
    ),

    Testimonial(
      quote: """
Thanks @mbrandonw @stephencelis for the very pedagogical series with @pointfreeco Excited and looking forward to learn from the series
""",
      subscriber: "Prakash Rajendran",
      tweetUrl: "https://twitter.com/dearprakash/status/1063165370159259648",
      twitterHandle: "dearprakash"
    ),

    Testimonial(
      quote: """
Just became a subscriber! I'm binge watching episodes now! Great content! I'm learning so much from you guys. The repo for the site is the best go - to reference for a well done project and swift-web is something I am definitely going to use in my projects. Thanks for everything!
""",
      subscriber: "William Savary",
      tweetUrl: "https://twitter.com/NSHumanBeing/status/1043141855884587008",
      twitterHandle: "NSHumanBeing"
    ),

    Testimonial(
      quote: """
Due to the amount of discussions that reference @pointfreeco, we added their logo as an emoji in our slack.
""",
      subscriber: "Rui Peres",
      tweetUrl: "https://twitter.com/peres/status/1020263301039689733",
      twitterHandle: "peres"
    ),

    Testimonial(
      quote: """
Every single episode of @pointfreeco has been mind blowing. I feel like I've grown a lot as a developer since I started learning Swift and this kind of tutorials definitely help. Functional High Five to @mbrandonw and @stephencelis 🙌🏼
""",
      subscriber: "Romain Pouclet",
      tweetUrl: "https://twitter.com/Palleas/status/978997094408212480",
      twitterHandle: "Palleas"
    ),

    Testimonial(
      quote: """
Watching the key path @pointfreeco episodes, and I am like 🤯🤯🤯. Super cool
""",
      subscriber: "Felipe Espinoza",
      tweetUrl: "https://twitter.com/fespinozacast/status/978997512500666368",
      twitterHandle: "fespinozacast"
    ),

    Testimonial(
      quote: """
tfw you are excited for a 4 hour train ride because you'll have time to watch the new @pointfreeco episode 🤓🏔🚂 #MathInTheAlps #typehype
""",
      subscriber: "Meghan Kane",
      tweetUrl: "https://twitter.com/meghafon/status/978624999866105859",
      twitterHandle: "meghafon"
    ),

    Testimonial(
      quote: """
@pointfreeco ❤️: Thank you! 🧠: … The brain can’t say anything. It is blown away (🤯)!
""",
      subscriber: "Rajiv Jhoomuck",
      tweetUrl: "https://twitter.com/rajivjhoomuck/status/973178777768480771",
      twitterHandle: "rajivjhoomuck"
    ),

    Testimonial(
      quote: """
the @pointfreeco videos are fantastic, and such a gentle introduction to important ideas — seriously worth a look regardless of functional experience level
""",
      subscriber: "tom burns",
      tweetUrl: "https://twitter.com/tomburns/status/972535717300666368",
      twitterHandle: "tomburns"
    ),

    Testimonial(
      quote: """
I haven't really done much Swift, but watched this out of curiosity, & it's really well done. Perfectly walks through the mindset of a dev w/ an OO background & addresses their concerns one by one with solid info explaining the benefits of taking the FP approach. (The how & why.)
""",
      subscriber: "Josh Burgess",
      tweetUrl: "https://twitter.com/_joshburgess/status/971169503890624513",
      twitterHandle: "_joshburgess"
    ),

    Testimonial(
      quote: """
I listened to the first two episodes of @pointfreeco this weekend and it was the best presentation of FP fundamentals I've seen. Very thoughtful layout and progression of the material and motivations behind each introduced concept. Looking forward to watching the rest!
""",
      subscriber: "Christina Lee",
      tweetUrl: "https://twitter.com/RunChristinaRun/status/968920979320709120",
      twitterHandle: "RunChristinaRun"
    ),

    Testimonial(
      quote: """
Really love this episode - thanks @mbrandonw + @stephencelis! Understanding Swift types in terms of algebraic data types is such an elegant way of seeing the # of possible values your Swift types will represent 🤯 #Simplifyallthethings #GoodbyeComplexity
""",
      subscriber: "Meghan Kane",
      tweetUrl: "https://twitter.com/meghafon/status/966766186221461504",
      twitterHandle: "meghafon"
    ),

    Testimonial(
      quote: """
Point-Free is really challenging my perspective and approach to Swift. Props to @mbrandonw and @stephencelis for creating an interesting and engaging video series!
""",
      subscriber: "Hesham Salman",
      tweetUrl: "https://twitter.com/_IronHam/status/967496514506543104",
      twitterHandle: "_IronHam"
    ),

    Testimonial(
      quote: """
I really love the dynamics of @pointfreeco. The dance of “this is super nice because…” “yes, BUT….”. they clearly show what’s good, what’s not so good and keep continuously improving.
""",
      subscriber: "Alejandro Martinez",
      tweetUrl: "https://twitter.com/alexito4/status/1158982960466550784",
      twitterHandle: "alexito4"
    ),

    Testimonial(
      quote: """
Just finished the mini-series on enum properties by @pointfreeco! They pointed out what’s missing from enums in Swift and used SwiftSyntax to generate code to add the missing parts. Thanks for your work @stephencelis and @mbrandonw! #pointfree
""",
      subscriber: "David Piper",
      tweetUrl: "https://twitter.com/HeyDaveTheDev/status/1142664959509368832",
      twitterHandle: "HeyDaveTheDev"
    ),

    Testimonial(
      quote: """
So many concepts presented at #WWDC19  reminded me of @pointfreeco video series. 👏👏 So happy I watched it before coming to San Jose.
""",
      subscriber: "Oscar Alvarez",
      tweetUrl: "https://twitter.com/iOjCaR/status/1136719341376790528",
      twitterHandle: "iOjCaR"
    ),

    Testimonial(
      quote: """
I just watched the episode of @pointfreeco where Brandon and Stephen explain how curry is derived and it ALMOST literally blew my mind. Decomposed things are so simple to grasp ❤ I love how this series decompose and explains things very granular and simple
""",
      subscriber: "Esteban Torres",
      tweetUrl: "https://twitter.com/esttorhe/status/1063420584044965888",
      twitterHandle: "esttorhe"
    )
  ]
}

public let extraSubscriptionLandingStyles =
  Breakpoint.desktop.query(only: screen) {
    extraSubscriptionLandingDesktopStyles
    }
    <> planItem % width(.pct(100))
    <> testimonialContainer % (
      height(.px(380))
        <> key("-webkit-overflow-scrolling", "touch")
    )
    <> testimonialItem % (
      flex(grow: 0, shrink: 0, basis: .auto)
        <> width(.px(260))
        <> height(.px(380))
)

private let desktopBorderStyles =
  darkRightBorder % key("border-right", "1px solid #333")
    <> lightRightBorder % key("border-right", "1px solid #e8e8e8")
    <> lightBottomBorder % key("border-bottom", "1px solid #e8e8e8")

private let extraSubscriptionLandingDesktopStyles: Stylesheet =
  desktopBorderStyles
    <> planItem % width(.pct(25))
    <> testimonialContainer % height(.px(400))
    <> testimonialItem % width(.px(340))
    <> testimonialItem % height(.px(380))

private let darkRightBorder = CssSelector.class("dark-right-border-d")
private let lightRightBorder = CssSelector.class("light-right-border-d")
private let lightBottomBorder = CssSelector.class("light-bottom-border-d")
private let planItem = CssSelector.class("plan-item")
private let testimonialContainer = CssSelector.class("testimonial-container")
private let testimonialItem = CssSelector.class("testimonial-item")
