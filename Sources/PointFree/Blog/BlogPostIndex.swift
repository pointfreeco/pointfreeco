import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func newsletterIndex(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.assets) var assets

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: "A companion blog to Point-Free, exploring advanced topics in Swift.",
        image: "https://d1iqsrac68iyd8.cloudfront.net/common/pfp-social-logo.jpg",
        title: "Point-Free Pointers",
        usePrismJs: true
      )
    ) {
      NewsletterIndex()
    }
}
