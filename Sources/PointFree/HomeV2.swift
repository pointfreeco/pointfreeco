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
      GridRowV2(alignment: .center) {
        h1 {
          "Explore the wonderful world of Swift."
        }
        .color(.white)
        .inlineStyle("margin", "0 auto")

//        p {
//          """
//          Point-Free is a video series about combining functional programming concepts with the
//          Swift programming language.
//          """
//        }
//        .color(.white)
      }
      .padding(topBottom: .large, leftRight: .medium)
      .padding(.extraLarge, .desktop)
    }
    .backgroundColor(.black)
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
