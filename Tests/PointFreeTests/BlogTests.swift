import Either
import HttpPipeline
@testable import Models
import ModelsTestSupport
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class BlogTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testBlogIndex() {
    let conn = connection(from: request(to: .blog(.index)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2000))
        ]
      )
    }
    #endif
  }

  func testBlogIndex_WithLotsOfPosts() {
    let shortMock = BlogPost.mock |> \.contentBlocks .~ [BlogPost.mock.contentBlocks[1]]
    let posts = [
      shortMock,
      shortMock,
      shortMock,
      shortMock |> \.hidden .~ true,
      shortMock,
      shortMock,
      shortMock
    ]

    update(
      &Current,
      \.blogPosts .~ unzurry(posts)
    )

    let conn = connection(from: request(to: .blog(.index)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2400)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2400))
        ]
      )
    }
    #endif
  }

  func testBlogShow() {
    let slug = Current.blogPosts().first!.slug
    let conn = connection(from: request(to: .blog(.show(slug: slug))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2000))
        ]
      )
    }
    #endif
  }

  func testBlogShow_Unauthed() {
    let slug = Current.blogPosts().first!.slug
    let conn = connection(from: request(to: .blog(.show(slug: slug))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogAtomFeed() {
    let conn = connection(from: request(to: .blog(.feed)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogAtomFeed_Unauthed() {
    let conn = connection(from: request(to: .blog(.feed)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
