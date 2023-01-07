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
  static var liveValue: Logger {
    Logger(label: ProcessInfo.processInfo.processName)
  }
}
