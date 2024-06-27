import StyleguideV2
import Dependencies
import PointFreeRouter

public struct Home: HTML {
  @Dependency(\.siteRouter) var siteRouter

  public init () {}

  public var body: some HTML {
    Grid {
      GridColumn {
        h1 {
          "Explore&nbsp;the&nbsp;wonderful world&nbsp;of&nbsp;Swift."
        }
        .inlineStyle("line-height", "1.2")
        .fontScale(.h2)
        .color(.white)
      }
      .column(count: 12)
      .column(count: 9, media: .desktop)
      .column(alignment: .center, media: .desktop)
      .inlineStyle("margin", "0 auto")

      GridColumn {
        p {
            """
            Point-Free is a a video series exploring advanced programming topics in the Swift
            programming language.
            """
        }
        .fontStyle(.body(.regular))
        .color(.gray800)
      }
      .column(count: 12)
      .column(count: 9, media: .desktop)
      .column(alignment: .center, media: .desktop)
      .inlineStyle("margin", "0 auto")

      GridColumn {
        Button(color: .purple, size: .regular, style: .normal) {
          "Start with a free episode →"
        }
        .attribute("href", siteRouter.loginPath(redirect: .homeV2))
      }
      .column(count: 12)
      .column(alignment: .center)
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding-top", "3rem")
    }
    .grid(alignment: .center)
    .padding(topBottom: .large, leftRight: .medium)
    .padding(.extraLarge, .desktop)
    .inlineStyle("background", "linear-gradient(#121212, #291a40)")

    Companies()
    WhatToExpect()
  }
}

struct Companies: HTML {
  var body: some HTML {
    Grid {
      GridColumn {
        "Trusted by teams"
      }
      .fontStyle(.body(.small))
      .inlineStyle("font-weight", "700")
      .inlineStyle("text-transform", "uppercase")
      .color(.purple)
      .column(count: 12)
      .column(alignment: .center)
      .inlineStyle("margin", "0 auto")
      .inlineStyle("padding", "3rem")
    }
    .grid(alignment: .center)
    .backgroundColor(.black)
  }
}

struct WhatToExpect: HTML {
  var body: some HTML {
    div {
      Grid {
        GridColumn {
          h1 {
            "What you can expect"
          }
          .fontScale(.h2)
          .color(.black)
          .color(.white, media: .dark)
        }
        .column(count: 12)
        .column(alignment: .center)
        .inlineStyle("margin", "4rem 0")

//        WhatToExpectItem.all.map { whatToExpect in 
//          GridColumn {
////            whatToExpect.title
//          }
////          .column(count: 1)
////          .column(count: 6)
//        }
      }
      .grid(alignment: .center)
      .inlineStyle("max-width", "1080px")
      .inlineStyle("margin", "0 auto")
    }
    .backgroundColor(.white)
    .backgroundColor(.gray150, media: .dark)
  }
}

//let homeMiddleware: M<Void> =
//writeStatus(.ok)
//>=> respond(
//  view: homeView(episodes:emergencyMode:),
//  layoutData: {
//    @Dependency(\.envVars.emergencyMode) var emergencyMode
//    @Dependency(\.episodes) var episodes
//
//    return SimplePageLayoutData(
//      data: (episodes(), emergencyMode),
//      openGraphType: .website,
//      style: .base(.mountains(.main)),
//      title:
//        ,
//      twitterCard: .summaryLargeImage
//    )
//  }
//)
