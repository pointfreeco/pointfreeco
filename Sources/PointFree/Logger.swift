import Foundation
#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public class StandardFileHandle: TextOutputStream {
  fileprivate let handle: FileHandle

  public static let error = StandardFileHandle(handle: .standardError)
  public static let output = StandardFileHandle(handle: .standardOutput)
  public static let null = StandardFileHandle(handle: .nullDevice)

  public init(handle: FileHandle) {
    self.handle = handle
  }

  public func write(_ string: String) {
    self.handle.write(Data(string.utf8))
  }
}

public class Logger {
  private let level: Level
  private var output: StandardFileHandle
  private var error: StandardFileHandle

  init(
    level: Level = .debug,
    output: StandardFileHandle = .output,
    error: StandardFileHandle = .error) {

    self.level = level
    self.output = output
    self.error = error
  }

  public func log<A>(
    _ level: Level,
    _ message: @autoclosure () -> A,
    file: StaticString = #file,
    line: UInt = #line) {

    let file = String(String(describing: file).split(separator: "/").last!)

    if level.rawValue >= self.level.rawValue {
      switch self.level {
      case .debug, .info, .warn:
        print("[\(self.level)] \(file):\(line): \(message())", to: &self.output)
        self.output.handle.synchronizeFile()
      case .error, .fatal:
        print("[\(self.level)] \(file):\(line): \(message())", to: &self.error)
        self.error.handle.synchronizeFile()
      }
    }
  }

  public func debug<A>(
    _ message: @autoclosure () -> A,
    file: StaticString = #file,
    line: UInt = #line) {

    self.log(.debug, message, file: file, line: line)
  }

  public func info<A>(
    _ message: @autoclosure () -> A,
    file: StaticString = #file,
    line: UInt = #line) {

    self.log(.info, message, file: file, line: line)
  }

  public func warn<A>(
    _ message: @autoclosure () -> A,
    file: StaticString = #file,
    line: UInt = #line) {

    self.log(.warn, message, file: file, line: line)
  }

  public func error<A>(
    _ message: @autoclosure () -> A,
    file: StaticString = #file,
    line: UInt = #line) {

    self.log(.error, message, file: file, line: line)
  }

  public func fatal<A>(
    _ message: @autoclosure () -> A,
    file: StaticString = #file,
    line: UInt = #line) {

    self.log(.fatal, message, file: file, line: line)
  }

  public enum Level: Int {
    case debug
    case info
    case warn
    case error
    case fatal
  }
}

import Either

public func logError<A>(
  subject: String,
  file: StaticString = #file,
  line: UInt = #line
  ) -> (Error) -> EitherIO<Error, A> {

  return { error in
    var errorDump = ""
    dump(error, to: &errorDump)
    Current.logger.log(.error, errorDump, file: file, line: line)

    return throwE(error)
  }
}
