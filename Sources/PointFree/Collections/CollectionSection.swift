import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionSectionMiddleware:
  M<
    Tuple5<
      User?, SubscriberState, SiteRoute, Episode.Collection.Slug, Episode.Collection.Section.Slug
    >
  > =
    fetchCollectionSectionMiddleware
    <| map(lower)
    >>> collectionSectionEndpoint

let collectionSectionEndpoint:
  M<(User?, SubscriberState, SiteRoute, Episode.Collection, Episode.Collection.Section)> =
    writeStatus(.ok)
    >=> respond(
      view: collectionSection,
      layoutData: { currentUser, currentSubscriberState, currentRoute, collection, section in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: currentSubscriberState,
          currentUser: currentUser,
          data: (collection, section),
          description: section.blurb,
          extraStyles: collectionsStylesheet,
          style: .base(.some(.minimal(.black))),
          title: collection.title + " › " + section.title
        )
      }
    )

private let fetchCollectionSectionMiddleware:
  MT<
    Tuple5<
      User?, SubscriberState, SiteRoute, Episode.Collection.Slug, Episode.Collection.Section.Slug
    >,
    Tuple5<User?, SubscriberState, SiteRoute, Episode.Collection, Episode.Collection.Section>
  > = filterMap(
    {
      let (user, subscriberState, route, collectionSlug, sectionSlug) = lower($0)
      return pure(
        Current.collections.first(where: { $0.slug == collectionSlug }).flatMap { collection in
          collection.sections.first(where: { $0.slug == sectionSlug }).map { section in
            lift((user, subscriberState, route, collection, section))
          }
        })
    },
    or: routeNotFoundMiddleware
  )
