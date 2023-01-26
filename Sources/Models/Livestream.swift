import Foundation
import Tagged

public struct Livestream: Codable, Identifiable {
  public let id: Tagged<Self, UUID>
  public let eventID: EventID
  public let isActive: Bool
  public let isLive: Bool

  public typealias EventID = Tagged<(eventID: (), Self), Int>

  public enum CodingKeys: String, CodingKey {
    case id
    case eventID = "event_id"
    case isActive = "is_active"
    case isLive = "is_live"
  }
}
