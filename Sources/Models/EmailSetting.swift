public struct EmailSetting: Codable, Equatable {
  public var newsletter: Newsletter
  public var userId: User.ID

  public init(newsletter: Newsletter, userId: User.ID) {
    self.newsletter = newsletter
    self.userId = userId
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
      .welcomeEmails,
    ]

    public static let subscriberNewsletters: [Newsletter] = [
      .announcements,
      .newBlogPost,
      .newEpisode,
    ]
  }
}
