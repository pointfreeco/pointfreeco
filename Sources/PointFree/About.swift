import Css
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let aboutResponse:
  Middleware<StatusLineOpen, ResponseEnded, (User?, SubscriberState, SiteRoute?), Data> =
    writeStatus(.ok)
    >=> respond(
      view: aboutView,
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: [.brandon, .stephen],
          extraStyles: aboutExtraStyles,
          title: "About"
        )
      }
    )
