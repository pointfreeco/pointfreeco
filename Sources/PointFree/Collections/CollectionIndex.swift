import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import Views

let collectionsIndexMiddleware: M<Void> =
  writeStatus(.ok)
  >=> respond(
    view: collectionIndex(collections:),
    layoutData: {
      SimplePageLayoutData(
        data: Current.collections,
        extraStyles: collectionIndexStyles,
        style: .base(.some(.minimal(.black))),
        title: "Point-Free Collections"
      )
    }
  )
