@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class DatabaseTests: TestCase {
  func testCreate() throws {
    let userA = try AppEnvironment.current.database.upsertUser(.mock, "hello@pointfree.co").run.perform().unwrap()
    let userB = try AppEnvironment.current.database.fetchUserById(userA!.id).run.perform().unwrap()
    XCTAssertEqual(userA?.id.unwrap, userB?.id.unwrap)
  }
}
