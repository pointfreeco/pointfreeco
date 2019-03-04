public struct NewBlogPostFormData: Codable, Equatable {
  public let nonsubscriberAnnouncement: String
  public let nonsubscriberDeliver: Bool?
  public let subscriberAnnouncement: String
  public let subscriberDeliver: Bool?
  
  public init(
    nonsubscriberAnnouncement: String,
    nonsubscriberDeliver: Bool?,
    subscriberAnnouncement: String,
    subscriberDeliver: Bool?) {
    self.nonsubscriberAnnouncement = nonsubscriberAnnouncement
    self.nonsubscriberDeliver = nonsubscriberDeliver
    self.subscriberAnnouncement = subscriberAnnouncement
    self.subscriberDeliver = subscriberDeliver
  }
  
  public enum CodingKeys: String, CodingKey {
    case nonsubscriberAnnouncement = "nonsubscriber_announcement"
    case nonsubscriberDeliver = "nonsubscriber_deliver"
    case subscriberAnnouncement = "subscriber_announcement"
    case subscriberDeliver = "subscriber_deliver"
  }
}
