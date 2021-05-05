public struct Flash: Codable, Equatable {
  public enum Priority: String, Codable {
    case error
    case notice
    case warning
  }

  public let message: String
  public let priority: Priority

  public init(
    _ priority: Priority,
    _ message: String
  ) {
    self.priority = priority
    self.message = message
  }
}
