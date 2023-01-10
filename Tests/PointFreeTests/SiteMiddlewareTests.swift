import HtmlSnapshotTesting
import HttpPipelineTestSupport
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import HttpPipeline
@testable import PointFree

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

private func secureRequest(_ urlString: String) -> URLRequest {
  var request = URLRequest(url: URL(string: urlString)!)
  request.allHTTPHeaderFields = ["X-Forwarded-Proto": "https"]
  return request
}

@MainActor
class SiteMiddlewareTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording=true
  }

  func testWithoutWWW() async throws {
    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: secureRequest("https://pointfree.co"))
      ),
      as: .conn
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: secureRequest("https://pointfree.co/episodes"))
      ),
      as: .conn
    )
  }

  func testWithoutHeroku() async throws {
    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: secureRequest("https://pointfreeco.herokuapp.com"))
      ),
      as: .conn
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: secureRequest("https://pointfreeco.herokuapp.com/episodes"))
      ),
      as: .conn
    )
  }

  func testWithWWW() async throws {
    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: secureRequest("https://www.pointfree.co"))
      ),
      as: .conn
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: secureRequest("https://www.pointfree.co"))
      ),
      as: .conn
    )
  }

  func testWithHttps() async throws {
    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: URLRequest(url: URL(string: "http://www.pointfree.co")!))
      ),
      as: .conn,
      named: "1.redirects_to_https"
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: URLRequest(url: URL(string: "http://www.pointfree.co/episodes")!))
      ),
      as: .conn,
      named: "2.redirects_to_https"
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: URLRequest(url: URL(string: "http://0.0.0.0:8080/")!))
      ),
      as: .conn,
      named: "0.0.0.0_allowed"
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: URLRequest(url: URL(string: "http://127.0.0.1:8080/")!))
      ),
      as: .conn,
      named: "127.0.0.0_allowed"
    )

    await assertSnapshot(
      matching: await siteMiddleware(
        connection(from: URLRequest(url: URL(string: "http://localhost:8080/")!))
      ),
      as: .conn,
      named: "localhost_allowed"
    )
  }
}
