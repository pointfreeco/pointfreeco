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
    withDependencies {
      $0.database = .mock
      $0.date.now = .mock
      $0.envVars = $0.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
      $0.gitHub = .mock
      $0.mailgun = .mock
      $0.stripe = .mock
      $0.uuid = .incrementing
    } operation: {
      super.invokeTest()
    }
  }

  override open func setUp() async throws {
    try await super.setUp()
    diffTool = "ksdiff"
    //SnapshotTesting.isRecording = true
  }

  override open func tearDown() {
    super.tearDown()
    SnapshotTesting.isRecording = false
  }

  public var isScreenshotTestingAvailable: Bool {
    ProcessInfo.processInfo.environment["CI"] == nil
  }
}

open class LiveDatabaseTestCase: XCTestCase {
  var pool: EventLoopGroupConnectionPool<PostgresConnectionSource>!

  open override class func setUp() {
    super.setUp()
    Backtrace.install()
  }

  override open func setUp() async throws {
    try await super.setUp()
    diffTool = "ksdiff"
    //SnapshotTesting.isRecording = true
    try await DependencyValues._current.database.resetForTesting(pool: self.pool)
  }

  open override func invokeTest() {
    withDependencies {
      $0.date.now = .mock
      $0.envVars = $0.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
      var str = ""
      dump(ProcessInfo.processInfo.environment, to: &str)
      print(str)
      print("-------------")
      str = ""
      dump($0.envVars, to: &str)
      print(str)
      fatalError()
      $0.gitHub = .mock
      $0.mailgun = .mock
      $0.stripe = .mock
      $0.uuid = .incrementing

      precondition(!Current.envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com"))
      self.pool = EventLoopGroupConnectionPool(
        source: PostgresConnectionSource(
          configuration: PostgresConfiguration(
            url: Current.envVars.postgres.databaseUrl.rawValue
          )!
        ),
        on: MultiThreadedEventLoopGroup(numberOfThreads: 1)
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

  public var isScreenshotTestingAvailable: Bool {
    ProcessInfo.processInfo.environment["CI"] == nil
  }
}
