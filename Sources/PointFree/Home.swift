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
      SimplePageLayoutData(
        data: (Current.episodes(), Current.envVars.emergencyMode),
        extraStyles: markdownBlockStyles,
        openGraphType: .website,
        style: .base(.mountains(.main)),
        title:
          "Point-Free: A video series on functional programming and the Swift programming language.",
        twitterCard: .summaryLargeImage
      )
    }
  )
