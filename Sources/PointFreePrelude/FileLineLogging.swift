import Logging

extension Logger {
  @inlinable
  public func log(
    _ level: Logger.Level,
    _ message: @autoclosure () -> Logger.Message,
    metadata: Logger.Metadata? = nil,
    file: String = #file,
    function: String = #function,
    line: UInt = #line
  ) {
    self.log(
      level: level,
      message(),
      metadata: (metadata ?? [:]).merging(
        ["file": "\(file)", "line": "\(line)"], uniquingKeysWith: { $1 }),
      file: file,
      function: function,
      line: line
    )
  }
}
