import Backtrace
import Database
import Dependencies
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

  open override func invokeTest() {
    DependencyValues.withTestValues {
      $0.envVars = $0.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
    } operation: {
      super.invokeTest()
    }
  }

  override open func setUp() async throws {
    try await super.setUp()
    diffTool = "ksdiff"
    //    SnapshotTesting.isRecording = true
    //Current = .mock 
    // siteRouter = PointFreeRouter(baseURL: Current.envVars.baseUrl) // TODO: not needed?
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

  override open func setUp() async throws {
    try await super.setUp()

    diffTool = "ksdiff"
    //    SnapshotTesting.isRecording = true

    try await Current.database.resetForTesting(pool: pool)
  }

  open override func invokeTest() {
    DependencyValues.withTestValues {
      // TODO: simplify
      precondition(!Current.envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com"))
      self.pool = EventLoopGroupConnectionPool(
        source: PostgresConnectionSource(
          configuration: PostgresConfiguration(
            url: Current.envVars.postgres.databaseUrl.rawValue
          )!
        ),
        on: self.eventLoopGroup
      )
      $0.database = .live(pool: self.pool)
    } operation: {
      super.invokeTest()
    }
  }

  override open func tearDown() {
    super.tearDown()
    SnapshotTesting.isRecording = false
  }
}
