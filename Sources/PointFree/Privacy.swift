import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let privacyResponse: Middleware<StatusLineOpen, ResponseEnded, Void, Data> =
  writeStatus(.ok)
  >=> respond(
    view: { _ in privacyView },
    layoutData: {
      SimplePageLayoutData(
        data: unit,
        title: "Privacy Policy"
      )
    }
  )
