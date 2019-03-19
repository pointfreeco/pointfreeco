import Foundation
import PointFreePrelude
import Tagged

public struct EnterpriseAccount: Decodable, Equatable {
  public var companyName: String
  public var domain: Domain
  public var id: Id
  public var subscriptionId: Subscription.Id

  public init(
    companyName: String,
    domain: Domain,
    id: Id,
    subscriptionId: Subscription.Id
    ) {
    self.companyName = companyName
    self.domain = domain
    self.id = id
    self.subscriptionId = subscriptionId
  }

  public typealias Domain = Tagged<EnterpriseAccount, String>
  public typealias Id = Tagged<EnterpriseAccount, UUID>

  private enum CodingKeys: String, CodingKey {
    case companyName = "company_name"
    case domain
    case id
    case subscriptionId = "subscription_id"
  }
}

public struct EnterpriseLink: Codable, Equatable{
  public var localPart: EmailLocalPart

  public enum CodingKeys: String, CodingKey {
    case localPart = "local_part"
  }
}
