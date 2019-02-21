import XCTest
@testable import Models

final class BlogPostTests: XCTestCase {

  func testSlug() {
    var post = BlogPost.mock
    post.id = 42
    post.title = "Launching Point-Free Pointers"

    XCTAssertEqual("42-launching-point-free-pointers", post.slug)
  }
}
