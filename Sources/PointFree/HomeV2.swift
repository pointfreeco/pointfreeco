import Foundation
import Html
import HttpPipeline
import Views

func homeV2Middleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {

  conn
    .writeStatus(.ok)
    .respondV2(
      view: homeV2View(),
      layoutData: SimplePageLayoutData(
        data: (),
        description: "Testing",
        extraHead: [],
        extraStyles: .empty,
        image: "",
        isGhosting: false,
        openGraphType: .website,
        style: .minimal,
        title: "Testing",
        twitterCard: .summaryLargeImage,
        usePrismJs: false
      )
    )
}

func homeV2View() -> Node {
  [
    "Homepage!"
  ]
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
//        "Point-Free: A video series exploring advanced programming topics in Swift.",
//      twitterCard: .summaryLargeImage
//    )
//  }
//)
