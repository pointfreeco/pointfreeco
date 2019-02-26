public struct EmailSetting: Codable, Equatable {
  public var newsletter: Newsletter
  public var userId: User.Id

  public init(newsletter: Newsletter, userId: User.Id) {
    self.newsletter = newsletter
    self.userId = userId
  }

  public enum CodingKeys: String, CodingKey {
    case newsletter
    case userId = "user_id"
  }

  public enum Newsletter: String, RawRepresentable, Codable, Equatable {
    case announcements
    case newBlogPost
    case newEpisode
    case welcomeEmails

    public static let allNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode,
      .welcomeEmails
    ]

    public static let subscriberNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode
    ]
  }
}
