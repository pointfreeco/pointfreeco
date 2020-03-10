import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionMiddleware
  : M<Tuple4<User?, SubscriberState, Route, Episode.Collection.Slug>>
  = basicAuth(
    user: Current.envVars.basicAuth.username,
    password: Current.envVars.basicAuth.password
    )
    <<< fetchCollectionMiddleware
    <| map(lower)
    >>> { conn in
      let (user, subscriberState, route, collection) = conn.data
      if collection.sections.count == 1 {
        return conn.map(const((user, subscriberState, route, collection, collection.sections[0])))
          |> collectionSectionEndpoint
      } else {
        return conn
          |> writeStatus(.ok)
          >=> respond(
            view: collectionShow,
            layoutData: { currentUser, currentSubscriberState, currentRoute, collection in
              SimplePageLayoutData(
                currentRoute: currentRoute,
                currentSubscriberState: currentSubscriberState,
                currentUser: currentUser,
                data: collection,
                description: collection.blurb,
                extraStyles: collectionsStylesheet,
                style: .base(.some(.minimal(.black))),
                title: collection.title
              )
          }
        )
      }
}

private let fetchCollectionMiddleware
  : MT<
  Tuple4<User?, SubscriberState, Route, Episode.Collection.Slug>,
  Tuple4<User?, SubscriberState, Route, Episode.Collection>
  >
  = filterMap(
    over4(fetchCollection >>> pure) >>> sequence4 >>> map(require4),
    or: routeNotFoundMiddleware
)

private func fetchCollection(_ slug: Episode.Collection.Slug) -> Episode.Collection? {
  Current.collections.first(where: { $0.slug == slug })
}
