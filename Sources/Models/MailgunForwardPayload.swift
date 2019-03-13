import HttpPipeline
import PointFreePrelude
import Tagged

public struct MailgunForwardPayload: Codable, Equatable {
  public typealias ApiKey = Tagged<MailgunForwardPayload, String>

  public let recipient: EmailAddress
  public let timestamp: Int
  public let token: String
  public let sender: EmailAddress
  public let signature: String
  
  public init(
    recipient: EmailAddress,
    timestamp: Int,
    token: String,
    sender: EmailAddress,
    signature: String) {
    self.recipient = recipient
    self.timestamp = timestamp
    self.token = token
    self.sender = sender
    self.signature = signature
  }

  public func verify(with apiKey: ApiKey) -> Bool {
    let digest = hexDigest(
      value: "\(self.timestamp)\(self.token)",
      asciiSecret: apiKey.rawValue
    )
    return self.signature == digest
  }
}
