import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

extension Conn where Step == StatusLineOpen, A == Void {
  func home() -> Conn<ResponseEnded, Data> {
    self
      .writeStatus(.ok)
      .respond(
        view: homeView(episodes:emergencyMode:),
        layoutData: {
          @Dependency(\.envVars.emergencyMode) var emergencyMode
          @Dependency(\.episodes) var episodes

          return SimplePageLayoutData(
            data: (episodes(), emergencyMode),
            openGraphType: .website,
            style: .base(.mountains(.main)),
            title: """
              Point-Free: A video series on functional programming and the Swift programming \
              language.
              """,
            twitterCard: .summaryLargeImage
          )
        }
      )
  }
}
