import Models
@testable import PointFree
import PointFreeTestSupport
import SnapshotTesting
import XCTest

final class SessionTests: TestCase {
  override func setUp() {
    super.setUp()
//    record=true
  }

  func testEncodable() {
    var session: Session
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted]

    _assertInlineSnapshot(matching: Session(flash: nil, user: nil), as: .json(JSONEncoder()), with: """
{}
""")

    session = Session(
      flash: nil,
      user: .standard(User.Id(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!))
    )
    _assertInlineSnapshot(matching: session, as: .json(JSONEncoder()), with: """
{"user":{"userId":"DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"}}
""")

    session = Session(
      flash: nil,
      user: .ghosting(
        ghosteeId: User.Id(rawValue: UUID(uuidString: "00000000-dead-beef-dead-beefdeadbeef")!),
        ghosterId: User.Id(rawValue: UUID(uuidString: "99999999-dead-beef-dead-beefdeadbeef")!)
      )
    )
    _assertInlineSnapshot(matching: session, as: .json(JSONEncoder()), with: """
{"user":{"ghosteeId":"00000000-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"99999999-DEAD-BEEF-DEAD-BEEFDEADBEEF"}}
""")
  }

  func testDecodable() throws {
    XCTAssertEqual(
      Session(flash: nil, user: nil),
      try JSONDecoder().decode(Session.self, from: Data("{}".utf8))
    )

    XCTAssertEqual(
      Session(
        flash: nil,
        user: .standard(User.Id(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!))
      ),
      try JSONDecoder().decode(
        Session.self,
        from: Data(#"{"user":{"userId":"DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"}}"#.utf8)
      )
    )

    XCTAssertEqual(
      Session(
        flash: nil,
        user: .ghosting(
          ghosteeId: User.Id(rawValue: UUID(uuidString: "00000000-dead-beef-dead-beefdeadbeef")!),
          ghosterId: User.Id(rawValue: UUID(uuidString: "99999999-dead-beef-dead-beefdeadbeef")!)
        )
      ),
      try JSONDecoder().decode(
        Session.self,
        from: Data(#"{"user":{"ghosteeId":"00000000-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"99999999-DEAD-BEEF-DEAD-BEEFDEADBEEF"}}"#.utf8)
      )
    )
  }
}
