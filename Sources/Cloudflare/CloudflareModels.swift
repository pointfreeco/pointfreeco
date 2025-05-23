public struct VideosEnvelope: Codable {
  public let result: [Video]
}

public struct VideoEnvelope: Codable {
  public let result: Video
}

public struct Video: Codable {
  public let uid: String
  public let meta: [String: String]
  public let publicDetails: PublicDetails
  public let size: Int

  public struct PublicDetails: Codable {
    public let channelLink: String?
    public let logo: String?
    public let shareLink: String?
    public let title: String?
    
    public init(
      channelLink: String? = nil,
      logo: String? = nil,
      shareLink: String? = nil,
      title: String? = nil
    ) {
      self.channelLink = channelLink
      self.logo = logo
      self.shareLink = shareLink
      self.title = title
    }

    private enum CodingKeys: String, CodingKey {
      case channelLink = "channel_link"
      case logo = "logo"
      case shareLink = "share_link"
      case title = "title"
    }
  }
}
