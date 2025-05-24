import Tagged

public struct Envelope<Result: Codable>: Codable {
  public let result: Result
}

public struct Image: Codable {
  public typealias ID = Tagged<Self, String>
  public let id: ID
  public let filename: String
  public let meta: [String: String]?
  public let variants: [String]
}

public struct Video: Codable {
  public typealias ID = Tagged<Self, String>

  public let uid: ID
  public let allowedOrigins: [String]
  public let meta: [String: String]
  public let publicDetails: PublicDetails
  public let size: Int

  public struct PublicDetails: Codable, Equatable {
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
