import Dependencies
import EnvVars
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let homeMiddleware: M<Void> =
  writeStatus(.ok)
  >=> respond(
    view: homeView(episodes:emergencyMode:),
    layoutData: {
      @Dependency(\.envVars.emergencyMode) var emergencyMode
      @Dependency(\.episodes) var episodes

      return SimplePageLayoutData(
        data: (episodes(), emergencyMode),
        openGraphType: .website,
        style: .base(.mountains(.main)),
        title:
          "Point-Free: A video series on functional programming and the Swift programming language.",
        twitterCard: .summaryLargeImage
      )
    }
  )
