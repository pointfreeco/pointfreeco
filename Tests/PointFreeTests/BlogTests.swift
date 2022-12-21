import Dependencies
import Either
import HttpPipeline
import ModelsTestSupport
import PointFreePrelude
import PointFreeRouter
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import Models
@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

class BlogTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.record = true
  }

  func testBlogIndex() {
    let conn = connection(from: request(to: .blog()))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testBlogIndex_WithLotsOfPosts() {
    var shortMock = BlogPost.testValue()[0]
    shortMock.contentBlocks = [shortMock.contentBlocks[1]]
    var hiddenMock = shortMock
    hiddenMock.hidden = true
    let posts = [
      shortMock,
      shortMock,
      shortMock,
      hiddenMock,
      shortMock,
      shortMock,
      shortMock,
    ]

    DependencyValues.withValues {
      $0.blogPosts = unzurry(posts)
    } operation: {
      let conn = connection(from: request(to: .blog()))
      assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

#if !os(Linux)
      if self.isScreenshotTestingAvailable {
        assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2400)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2400)),
          ]
        )
      }
#endif
    }
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
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2000)),
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
