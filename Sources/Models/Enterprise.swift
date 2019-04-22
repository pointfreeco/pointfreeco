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

public struct EnterpriseRequestFormData: Codable, Equatable {
  public var email: EmailAddress

  public enum CodingKeys: String, CodingKey {
    case email
  }

  public init(email: EmailAddress) {
    self.email = email
  }
}

public struct EnterpriseEmail: Decodable, Equatable {
  public var id: Id
  public var email: EmailAddress
  public var userId: User.Id

  public typealias Id = Tagged<EnterpriseEmail, UUID>

  private enum CodingKeys: String, CodingKey {
    case id
    case email
    case userId = "user_id"
  }

  public init(id: Id, email: EmailAddress, userId: User.Id) {
    self.id = id
    self.email = email
    self.userId = userId
  }
}
