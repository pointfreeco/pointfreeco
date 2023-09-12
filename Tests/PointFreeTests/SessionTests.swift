import InlineSnapshotTesting
import Models
import PointFreeTestSupport
import XCTest

@testable import PointFree

final class SessionTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testEncodable() async throws {
    var session: Session
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    #if !os(Linux)
      // Can't run on Linux because of https://bugs.swift.org/browse/SR-11410
      await assertInlineSnapshot(of: Session(flash: nil, user: nil), as: .json(encoder)) {
        """
        {

        }
        """
      }
    #endif

    session = Session(
      flash: nil,
      user: .standard(User.ID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
    )
    await assertInlineSnapshot(of: session, as: .json(encoder)) {
      """
      {
        "userId" : "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF"
      }
      """
    }

    session = Session(
      flash: nil,
      user: .ghosting(
        ghosteeId: User.ID(uuidString: "00000000-dead-beef-dead-beefdeadbeef")!,
        ghosterId: User.ID(uuidString: "99999999-dead-beef-dead-beefdeadbeef")!
      )
    )
    await assertInlineSnapshot(of: session, as: .json(encoder)) {
      """
      {
        "user" : {
          "ghosteeId" : "00000000-DEAD-BEEF-DEAD-BEEFDEADBEEF",
          "ghosterId" : "99999999-DEAD-BEEF-DEAD-BEEFDEADBEEF"
        }
      }
      """
    }
  }

  func testDecodable() async throws {
    XCTAssertEqual(
      Session(flash: nil, user: nil),
      try JSONDecoder().decode(Session.self, from: Data("{}".utf8))
    )

    XCTAssertEqual(
      Session(
        flash: nil,
        user: .standard(
          User.ID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
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
          User.ID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
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
          ghosteeId: User.ID(uuidString: "00000000-dead-beef-dead-beefdeadbeef")!,
          ghosterId: User.ID(uuidString: "99999999-dead-beef-dead-beefdeadbeef")!
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
