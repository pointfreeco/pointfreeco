import Css
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func aboutResponse(
  _ conn: Conn<StatusLineOpen, (User?, SubscriberState, SiteRoute?)>
) -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(view: aboutView) { currentUser, subscriberState, currentRoute in
      SimplePageLayoutData(
        currentRoute: currentRoute,
        currentSubscriberState: subscriberState,
        currentUser: currentUser,
        data: [.brandon, .stephen],
        extraStyles: aboutExtraStyles,
        title: "About"
      )
    }
}
