import Models
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import PointFree

final class SessionTests: TestCase {
  override func setUp() {
    super.setUp()
    //    SnapshotTesting.record=true
  }

  func testEncodable() {
    var session: Session
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    #if !os(Linux)
      // Can't run on Linux because of https://bugs.swift.org/browse/SR-11410
      _assertInlineSnapshot(
        matching: Session(flash: nil, user: nil), as: .json(encoder),
        with: """
          {

          }
          """)
    #endif

    session = Session(
      flash: nil,
      user: .standard(User.ID(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!))
    )
    _assertInlineSnapshot(
      matching: session, as: .json(encoder),
      with: """
        {
          "userId" : "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"
        }
        """)

    session = Session(
      flash: nil,
      user: .ghosting(
        ghosteeId: User.ID(rawValue: UUID(uuidString: "00000000-dead-beef-dead-beefdeadbeef")!),
        ghosterId: User.ID(rawValue: UUID(uuidString: "99999999-dead-beef-dead-beefdeadbeef")!)
      )
    )
    _assertInlineSnapshot(
      matching: session, as: .json(encoder),
      with: """
        {
          "user" : {
            "ghosteeId" : "00000000-DEAD-BEEF-DEAD-BEEFDEADBEEF",
            "ghosterId" : "99999999-DEAD-BEEF-DEAD-BEEFDEADBEEF"
          }
        }
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
        user: .standard(
          User.ID(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!))
      ),
      try JSONDecoder().decode(
        Session.self,
        from: Data(#"{"user":{"userId":"DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"}}"#.utf8)
      )
    )

    XCTAssertEqual(
      Session(
        flash: nil,
        user: .standard(
          User.ID(rawValue: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!))
      ),
      try JSONDecoder().decode(
        Session.self,
        from: Data(#"{"userId":"DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"}"#.utf8)
      )
    )

    XCTAssertEqual(
      Session(
        flash: nil,
        user: .ghosting(
          ghosteeId: User.ID(rawValue: UUID(uuidString: "00000000-dead-beef-dead-beefdeadbeef")!),
          ghosterId: User.ID(rawValue: UUID(uuidString: "99999999-dead-beef-dead-beefdeadbeef")!)
        )
      ),
      try JSONDecoder().decode(
        Session.self,
        from: Data(
          #"{"user":{"ghosteeId":"00000000-DEAD-BEEF-DEAD-BEEFDEADBEEF","ghosterId":"99999999-DEAD-BEEF-DEAD-BEEFDEADBEEF"}}"#
            .utf8)
      )
    )
  }
}
