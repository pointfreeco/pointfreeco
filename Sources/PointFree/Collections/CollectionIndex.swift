import Dependencies
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionsIndexMiddleware: M<Tuple3<User?, SubscriberState, SiteRoute?>> =
  map(lower)
  >>> writeStatus(.ok)
  >=> respond(
    view: collectionIndex(collections:),
    layoutData: { currentUser, subscriberState, route in
      @Dependency(\.collections) var collections
      return SimplePageLayoutData(
        currentRoute: route,
        currentSubscriberState: subscriberState,
        currentUser: currentUser,
        data: collections,
        extraStyles: collectionIndexStyles,
        style: .base(.some(.minimal(.black))),
        title: "Point-Free Collections"
      )
    }
  )
