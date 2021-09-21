import Database
import Models
import NIO
@testable import PointFree
import PointFreeRouter
import PostgresKit
import Prelude
import SnapshotTesting
import XCTest

open class LiveDatabaseTestCase: TestCase {
  var database: Database.Client!
  var pool: EventLoopGroupConnectionPool<PostgresConnectionSource>!
  let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

  override open func setUp() {
    super.setUp()

    precondition(Current.envVars.postgres.databaseUrl.contains("localhost"))
    self.pool = EventLoopGroupConnectionPool(
      source: PostgresConnectionSource(
        configuration: PostgresConfiguration(
          url: Current.envVars.postgres.databaseUrl
        )!
      ),
      on: self.eventLoopGroup
    )
    Current.database = .live(pool: self.pool)
    try! Current.database.resetForTesting(pool: pool)
  }
}

open class TestCase: XCTestCase {
  override open func setUp() {
    super.setUp()
    diffTool = "ksdiff"
//    SnapshotTesting.isRecording = true
    Current = .mock
    Current.envVars = Current.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
    pointFreeRouter = PointFreeRouter(baseUrl: Current.envVars.baseUrl)
  }

  override open func tearDown() {
    super.tearDown()
    SnapshotTesting.isRecording = false
  }

  public var isScreenshotTestingAvailable: Bool {
    ProcessInfo.processInfo.environment["CI"] == nil
  }
}
