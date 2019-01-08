import Either
import Html
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

class BlogTests: TestCase {
  override func setUp() {
    super.setUp()
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testBlogIndex() {
    let conn = connection(from: request(to: .blog(.index), basicAuth: true))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    update(
      &Current,
      \.blogPosts .~ unzurry((1...6).map(const(shortMock)))
    )

    let conn = connection(from: request(to: .blog(.index), basicAuth: true))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

  func testBlogIndex_Unauthed() {
    let conn = connection(from: request(to: .blog(.index), basicAuth: true))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogShow() {
    let conn = connection(from: request(to: .blog(.show(.mock)), basicAuth: true))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    let conn = connection(from: request(to: .blog(.show(.mock))))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogAtomFeed() {
    let conn = connection(from: request(to: .blog(.feed), basicAuth: true))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testBlogAtomFeed_Unauthed() {
    let conn = connection(from: request(to: .blog(.feed)))

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
