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
  public var useMockBaseDependencies = true

  open override class func setUp() {
    super.setUp()
  }

  open override func invokeTest() {
    withDependencies {
      if self.useMockBaseDependencies {
        $0.database = .mock
        $0.date.now = .mock
        $0.envVars = $0.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
        $0.gitHub = .mock
        $0.mailgun = .mock
        $0.stripe = .mock
        $0.uuid = .incrementing
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(Xoshiro(seed: 0))
      }
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
    //SnapshotTesting.isRecording = false
  }

  public var isScreenshotTestingAvailable: Bool {
    ProcessInfo.processInfo.environment["CI"] == nil
  }
}

open class LiveDatabaseTestCase: XCTestCase {
  public var useMockBaseDependencies = true
  var pool: EventLoopGroupConnectionPool<PostgresConnectionSource>!

  open override class func setUp() {
    super.setUp()
  }

  override open func setUp() async throws {
    try await super.setUp()
    diffTool = "ksdiff"
    //SnapshotTesting.isRecording = true
    @Dependency(\.database) var database
    try await database.resetForTesting(pool: self.pool)
  }

  open override func invokeTest() {
    withDependencies {
      if self.useMockBaseDependencies {
        $0.date.now = .mock
        $0.envVars = $0.envVars.assigningValuesFrom(ProcessInfo.processInfo.environment)
        $0.gitHub = .mock
        $0.mailgun = .mock
        $0.stripe = .mock
        $0.uuid = .incrementing
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(Xoshiro(seed: 0))
      }
      precondition(!$0.envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com"))
      self.pool = EventLoopGroupConnectionPool(
        source: PostgresConnectionSource(
          sqlConfiguration: try! SQLPostgresConfiguration(
            url: $0.envVars.postgres.databaseUrl.rawValue
          )
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

// http://xoshiro.di.unimi.it.
private struct Xoshiro: RandomNumberGenerator {
  var state: (UInt64, UInt64, UInt64, UInt64)
  init(seed: UInt64) {
    self.state = (seed, 18_446_744, 073_709, 551_615)
    for _ in 1...10 { _ = self.next() }  // perturb
  }
  mutating func next() -> UInt64 {
    let x = self.state.1 &* 5
    let result = ((x &<< 7) | (x &>> 57)) &* 9
    let t = self.state.1 &<< 17
    self.state.2 ^= self.state.0
    self.state.3 ^= self.state.1
    self.state.1 ^= self.state.2
    self.state.0 ^= self.state.3
    self.state.2 ^= t
    self.state.3 = (self.state.3 &<< 45) | (self.state.3 &>> 19)
    return result
  }
}
