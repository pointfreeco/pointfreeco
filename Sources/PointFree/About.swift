import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import View
import Views

let aboutResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple3<User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
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
