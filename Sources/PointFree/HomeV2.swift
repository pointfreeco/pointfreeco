import Foundation
import Html
import HttpPipeline
import StyleguideV2
import Views

func homeV2Middleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {

  conn
    .writeStatus(.ok)
    .respondV2(
      view: Node { Home() },
      layoutData: SimplePageLayoutData(
        description: "Point-Free: A video series exploring advanced programming topics in Swift.",
        extraHead: [],
        extraStyles: .empty,
        image: "",
        isGhosting: false,
        openGraphType: .website,
        style: .base(.minimal(.dark)),
        title: "Point-Free",
        twitterCard: .summaryLargeImage,
        usePrismJs: false
      )
    )
}

struct Home: HTML {
  var body: some HTML {
    div {
      GridRow(alignment: .center) {
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
      }
      .padding(topBottom: .large, leftRight: .medium)
      .padding(.extraLarge, .desktop)
    }
    .inlineStyle("background", "linear-gradient(#121212, #2A1A40)")
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
