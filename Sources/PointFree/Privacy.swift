import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let privacyResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple3<User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> _respond(
      view: { _ in privacyView },
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: unit,
          title: "Privacy Policy"
        )
    }
)
