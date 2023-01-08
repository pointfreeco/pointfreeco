import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionSectionMiddleware:
  M<Tuple2<Episode.Collection.Slug, Episode.Collection.Section.Slug>> =
    fetchCollectionSectionMiddleware
    <| collectionSectionEndpoint

let collectionSectionEndpoint: M<Tuple2<Episode.Collection, Episode.Collection.Section>> =
  writeStatus(.ok)
  >=> map(lower)
  >>> respond(
    view: collectionSection,
    layoutData: { collection, section in
      SimplePageLayoutData(
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
    Tuple2<Episode.Collection.Slug, Episode.Collection.Section.Slug>,
    Tuple2<Episode.Collection, Episode.Collection.Section>
  > = filterMap(
    {
      let (collectionSlug, sectionSlug) = lower($0)
      return pure(
        Current.collections.first(where: { $0.slug == collectionSlug }).flatMap { collection in
          collection.sections.first(where: { $0.slug == sectionSlug }).map { section in
            lift((collection, section))
          }
        })
    },
    or: routeNotFoundMiddleware
  )
