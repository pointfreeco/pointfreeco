import Either
import XCTest
@testable import PointFree
import PointFreeTestSupport
import Prelude

class EitherIOTests: TestCase {
  func testRetry_Fails() {
    var count = 0
    let thing = EitherIO<Prelude.Unit, Prelude.Unit>(run: IO {
      count += 1
      return count == 3 ? .right(unit) : .left(unit)
    })
      .retry(maxRetries: 2)

    let result = thing.run.perform()

    XCTAssertTrue(result.isLeft)
  }

  func testRetry_Succeeds() {
    var count = 0
    let thing = EitherIO<Prelude.Unit, Prelude.Unit>(run: IO {
      count += 1
      return count == 3 ? .right(unit) : .left(unit)
    })
      .retry(maxRetries: 3)

    let result = thing.run.perform()

    XCTAssertTrue(result.isRight)
  }
}
