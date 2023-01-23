import Foundation
import Tagged

public struct Livestream: Codable, Identifiable {
  public let id: Tagged<Self, UUID>
  public let eventID: Int
  public let isLive: Bool

  public enum CodingKeys: String, CodingKey {
    case id
    case eventID = "event_id"
    case isLive = "is_live"
  }
}
