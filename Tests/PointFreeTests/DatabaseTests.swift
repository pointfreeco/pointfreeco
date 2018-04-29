@testable import PointFree
import Optics
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

final class DatabaseTests: TestCase {
  func testCreate() throws {
    let userA = try Current.database.upsertUser(.mock, "hello@pointfree.co").run.perform().unwrap()
    let userB = try Current.database.fetchUserById(userA!.id).run.perform().unwrap()
    XCTAssertEqual(userA?.id, userB?.id)
  }
}
