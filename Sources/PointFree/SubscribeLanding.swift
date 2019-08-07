import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import View
import Views

import Css
import Either
import FunctionalCss
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Mailgun
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tagged
import Tuple
import UrlFormEncoding
import View
import Views

public let subscribeLanding: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, SubscriberState, Route>,
  Data
  > =
  requireAdmin
    <| writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: Views.subscribeLanding,
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: currentUser,
          title: "Subscribe to Point-Free"
        )
    }
)
