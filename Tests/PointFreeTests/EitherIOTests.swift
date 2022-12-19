import Either
import PointFreeTestSupport
import Prelude
import XCTest

@testable import PointFree

class EitherIOTests: TestCase {
  func testRetry_Fails() async {
    var count = 0
    let thing = EitherIO<Prelude.Unit, Prelude.Unit>(
      run: IO {
        count += 1
        return count == 3 ? .right(unit) : .left(unit)
      }
    )
    .retry(maxRetries: 2)

    let result = await thing.run.performAsync()

    XCTAssertTrue(result.isLeft)
  }

  func testRetry_Succeeds() async {
    var count = 0
    let thing = EitherIO<Prelude.Unit, Prelude.Unit>(
      run: IO {
        count += 1
        return count == 3 ? .right(unit) : .left(unit)
      }
    )
    .retry(maxRetries: 3)

    let result = await thing.run.performAsync()

    XCTAssertTrue(result.isRight)
  }

  func testRetry_MaxRetriesZero_Success() async {
    let thing = EitherIO<Prelude.Unit, Prelude.Unit>(
      run: IO {
        return .right(unit)
      }
    )
    .retry(maxRetries: 0)

    let result = await thing.run.performAsync()

    XCTAssertTrue(result.isRight)
  }

  func testRetry_MaxRetriesZero_Failure() async {
    let thing = EitherIO<Prelude.Unit, Prelude.Unit>(
      run: IO {
        return .left(unit)
      }
    )
    .retry(maxRetries: 0)

    let result = await thing.run.performAsync()

    XCTAssertTrue(result.isLeft)
  }
}
