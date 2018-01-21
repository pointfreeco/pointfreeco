import Either
import Prelude
#if os(Linux)
  import Glibc
#else
  import Darwin.C
#endif

public struct Logger {
  private(set) var level: Level = .debug
  private(set) var logger: (String) -> () = { print($0) }

  init(level: Level = .debug, logger: @escaping (String) -> () = { print($0) }) {
    self.level = level
    self.logger = logger
  }

  public func log<A>(_ level: Level, _ message: @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) {
    if level.rawValue >= self.level.rawValue {
      let fileName = String(describing: file).split(separator: "/").last ?? "Unknown.swift"
      self.logger("[\(level):\(fileName):\(line)] \(message())")
      fflush(stdout)
    }
  }

  public func logEitherIO<A, E>(_ level: Level, _ message: @escaping @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) -> EitherIO<E, A> {
    return EitherIO(run: IO {
      let value = message()
      self.log(level, value, file: file, line: line)
      return .right(value)
    })
  }

  public func logIO<A>(_ level: Level, _ message: @escaping @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) -> IO<A> {
    return IO {
      let value = message()
      self.log(level, value, file: file, line: line)
      return value
    }
  }

  public func debug<A>(_ message: @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) {
    self.log(.debug, message, file: file, line: line)
  }

  public func info<A>(_ message: @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) {
    self.log(.info, message, file: file, line: line)
  }

  public func warn<A>(_ message: @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) {
    self.log(.warn, message, file: file, line: line)
  }

  public func error<A>(_ message: @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) {
    self.log(.error, message, file: file, line: line)
  }

  public func fatal<A>(_ message: @autoclosure () -> A, file: StaticString = #file, line: UInt = #line) {
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
