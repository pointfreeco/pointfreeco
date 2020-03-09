import HttpPipeline
import Models
import PointFreePrelude
import Prelude
import Tuple
import Views

let collectionSectionMiddleware
  : M<Tuple4<User?, SubscriberState, Episode.Collection.Slug, Episode.Collection.Section.Slug>>
  = basicAuth(
    user: Current.envVars.basicAuth.username,
    password: Current.envVars.basicAuth.password
    )
    <<< fetchCollectionSectionMiddleware
    <| map(lower)
    >>> writeStatus(.ok)
    >=> respond(
      view: collectionSection,
      layoutData: { currentUser, _, collection, section in
        SimplePageLayoutData(
          currentUser: currentUser,
          data: (collection, section),
          extraStyles: collectionsStylesheet,
          style: .base(.some(.minimal(.black))),
          title: collection.title ?? "Point-Free"
        )
    }
)

private let fetchCollectionSectionMiddleware
  : MT<
  Tuple4<User?, SubscriberState, Episode.Collection.Slug, Episode.Collection.Section.Slug>,
  Tuple4<User?, SubscriberState, Episode.Collection, Episode.Collection.Section>
  >
  = filterMap(
    {
      let (user, subscriberState, collectionSlug, sectionSlug) = lower($0)
      return pure(Current.collections.first(where: { $0.slug == collectionSlug }).flatMap { collection in
        collection.sections.first(where: { $0.slug == sectionSlug }).map { section in
          lift((user, subscriberState, collection, section))
        }
      })
  },
    or: routeNotFoundMiddleware
)

private func fetchCollection(_ slug: Episode.Collection.Slug) -> Episode.Collection? {
  Current.collections.first(where: { $0.slug == slug })
}
