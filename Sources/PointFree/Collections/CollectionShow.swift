import Dependencies
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionMiddleware: M<Episode.Collection.Slug> =
  fetchCollectionMiddleware
  <| { conn in
    let collection = conn.data
    if collection.sections.count == 1 {
      return conn.map(const(collection .*. collection.sections[0] .*. unit))
        |> collectionSectionEndpoint
    } else {
      return conn
        |> writeStatus(.ok)
        >=> respond(
          view: collectionShow,
          layoutData: { collection in
            SimplePageLayoutData(
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

private let fetchCollectionMiddleware: MT<Episode.Collection.Slug, Episode.Collection> = {
  middleware in
  return { conn in
    guard let collection = fetchCollection(conn.data)
    else { return routeNotFoundMiddleware(conn) }

    return middleware(conn.map(const(collection)))
  }
}

private func fetchCollection(_ slug: Episode.Collection.Slug) -> Episode.Collection? {
  @Dependency(\.collections) var collections
  return collections.first(where: { $0.slug == slug })
}
