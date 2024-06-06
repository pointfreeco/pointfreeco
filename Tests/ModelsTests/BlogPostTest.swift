import Models
import ModelsTestSupport
import PointFreeTestSupport
import XCTest

final class BlogPostTests: TestCase {
  @MainActor
  func testSlug() async throws {
    var post = BlogPost.testValue()[0]
    post.id = 42
    post.title = "Launching Point-Free Pointers"

    XCTAssertEqual("42-launching-point-free-pointers", post.slug)
  }
}
