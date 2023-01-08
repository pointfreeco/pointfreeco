import Dependencies
import Foundation
import Models

private enum RequestIDKey: DependencyKey {
  static let liveValue = UUID()
  static let testValue = UUID()
}

extension DependencyValues {
  public var requestID: UUID {
    get { self[RequestIDKey.self] }
    set { self[RequestIDKey.self] = newValue }
  }
}
