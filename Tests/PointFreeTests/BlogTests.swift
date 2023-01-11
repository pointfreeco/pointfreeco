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

@MainActor
class BlogTests: TestCase {
  @Dependency(\.blogPosts) var blogPosts

  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.record = true
  }

  func testBlogIndex() async throws {
    let conn = connection(from: request(to: .blog()))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testBlogIndex_WithLotsOfPosts() async throws {
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

    await withDependencies {
      $0.blogPosts = unzurry(posts)
    } operation: {
      let conn = connection(from: request(to: .blog()))
      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
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

  func testBlogShow() async throws {
    let slug = self.blogPosts().first!.slug
    let conn = connection(from: request(to: .blog(.show(slug: slug))))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2000)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2000)),
          ]
        )
      }
    #endif
  }

  func testBlogShow_Unauthed() async throws {
    let slug = self.blogPosts().first!.slug
    let conn = connection(from: request(to: .blog(.show(slug: slug))))

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogAtomFeed() async throws {
    let conn = connection(from: request(to: .blog(.feed)))
    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogAtomFeed_Unauthed() async throws {
    let conn = connection(from: request(to: .blog(.feed)))
    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
