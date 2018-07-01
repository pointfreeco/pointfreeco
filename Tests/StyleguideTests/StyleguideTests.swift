import Css
import PointFreeTestSupport
import SnapshotTesting
import Styleguide
import XCTest

class StyleguideTests: TestCase {
  func testStyleguide() {
    assertSnapshot(
      matching: render(config: .pretty, css: styleguide),
      named: "pretty",
      pathExtension: "css"
    )
    assertSnapshot(
      matching: render(config: .compact, css: styleguide),
      named: "mini",
      pathExtension: "css"
    )
  }

  func testDesignSystem() {
    assertSnapshot(
      matching: render(config: .pretty, css: designSystems),
      named: "pretty",
      pathExtension: "css"
    )
    assertSnapshot(
      matching: render(config: .compact, css: designSystems),
      named: "mini",
      pathExtension: "css"
    )
  }

  func testPointFreeStyles() {
    assertSnapshot(
      matching: render(config: .pretty, css: pointFreeBaseStyles),
      named: "pretty",
      pathExtension: "css"
    )
    assertSnapshot(
      matching: render(config: .compact, css: pointFreeBaseStyles),
      named: "mini",
      pathExtension: "css"
    )
  }
}
