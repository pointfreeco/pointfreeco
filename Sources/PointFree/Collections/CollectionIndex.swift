import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionsIndexMiddleware: M<Tuple3<User?, SubscriberState, Route?>>
  = basicAuth(
    user: Current.envVars.basicAuth.username,
    password: Current.envVars.basicAuth.password
    )
    <| map(lower)
    >>> writeStatus(.ok)
    >=> respond(
      view: collectionIndex(collections:),
      layoutData: { currentUser, subscriberState, route in
        SimplePageLayoutData(
          currentRoute: route,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: Current.collections,
          extraStyles: collectionIndexStyles,
          style: .base(.some(.minimal(.black))),
          title: "Point-Free Collections"
        )
    }
)
