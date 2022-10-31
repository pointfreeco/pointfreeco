import Backtrace
import Database
import Models
import NIO
import PointFreeRouter
import PostgresKit
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

open class TestCase: XCTestCase {
  open override class func setUp() {
    super.setUp()
    Backtrace.install()
  }

  override open func setUp() {
    super.setUp()
    diffTool = "ksdiff"
    //    SnapshotTesting.isRecording = true
    Current = .mock
    Current.envVars = Current.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
    siteRouter = PointFreeRouter(baseURL: Current.envVars.baseUrl)
  }

  override open func tearDown() {
    super.tearDown()
    SnapshotTesting.isRecording = false
  }

  public var isScreenshotTestingAvailable: Bool {
    ProcessInfo.processInfo.environment["CI"] == nil
  }
}

open class LiveDatabaseTestCase: TestCase {
  var database: Database.Client!
  var pool: EventLoopGroupConnectionPool<PostgresConnectionSource>!
  let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

  override open func setUp() {
    super.setUp()

    diffTool = "ksdiff"
    //    isRecording = true

    precondition(!Current.envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com"))
    self.pool = EventLoopGroupConnectionPool(
      source: PostgresConnectionSource(
        configuration: PostgresConfiguration(
          url: Current.envVars.postgres.databaseUrl.rawValue
        )!
      ),
      on: self.eventLoopGroup
    )
    Current.database = .live(pool: self.pool)
    try! Current.database.resetForTesting(pool: pool)
  }
}
