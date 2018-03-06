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

  public func log<A>(_ level: Level, _ message: @autoclosure () -> A) {
    if level.rawValue >= self.level.rawValue {
//      self.logger(String(describing: message()))
//      fflush(stdout)
    }
  }

  public func debug<A>(_ message: @autoclosure () -> A) {
    self.log(.debug, message)
  }

  public func info<A>(_ message: @autoclosure () -> A) {
    self.log(.info, message)
  }

  public func warn<A>(_ message: @autoclosure () -> A) {
    self.log(.warn, message)
  }

  public func error<A>(_ message: @autoclosure () -> A) {
    self.log(.error, message)
  }

  public func fatal<A>(_ message: @autoclosure () -> A) {
    self.log(.fatal, message)
  }

  public enum Level: Int {
    case debug
    case info
    case warn
    case error
    case fatal
  }
}
