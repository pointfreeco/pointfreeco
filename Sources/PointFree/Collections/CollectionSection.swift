import HttpPipeline
import Models
import PointFreeRouter
import PointFreePrelude
import Prelude
import Tuple
import Views

let collectionSectionMiddleware
  : M<Tuple5<User?, SubscriberState, Route, Episode.Collection.Slug, Episode.Collection.Section.Slug>>
  = basicAuth(
    user: Current.envVars.basicAuth.username,
    password: Current.envVars.basicAuth.password
    )
    <<< fetchCollectionSectionMiddleware
    <| map(lower)
    >>> writeStatus(.ok)
    >=> respond(
      view: collectionSection,
      layoutData: { currentUser, currentSubscriberState, currentRoute, collection, section in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: currentSubscriberState,
          currentUser: currentUser,
          data: (collection, section),
          extraStyles: collectionsStylesheet,
          style: .base(.some(.minimal(.black))),
          title: collection.title
        )
    }
)

private let fetchCollectionSectionMiddleware
  : MT<
  Tuple5<User?, SubscriberState, Route, Episode.Collection.Slug, Episode.Collection.Section.Slug>,
  Tuple5<User?, SubscriberState, Route, Episode.Collection, Episode.Collection.Section>
  >
  = filterMap(
    {
      let (user, subscriberState, route, collectionSlug, sectionSlug) = lower($0)
      return pure(Episode.Collection.all.first(where: { $0.slug == collectionSlug }).flatMap { collection in
        collection.sections.first(where: { $0.slug == sectionSlug }).map { section in
          lift((user, subscriberState, route, collection, section))
        }
      })
  },
    or: routeNotFoundMiddleware
)
