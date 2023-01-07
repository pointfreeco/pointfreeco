import Dependencies
import Foundation
import Logging

extension DependencyValues {
  public var logger: Logger {
    get { self[LoggerKey.self] }
    set { self[LoggerKey.self] = newValue }
  }
}

private enum LoggerKey: DependencyKey {
  static let testValue = Logger(label: ProcessInfo.processInfo.processName)
  static let liveValue = Logger(label: ProcessInfo.processInfo.processName)
}
