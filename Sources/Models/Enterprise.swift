import EmailAddress
import Foundation
import Tagged

public struct EnterpriseAccount: Decodable, Equatable, Identifiable {
  public var ciToken: CIToken
  public var companyName: String
  public var domain: Domain
  public var domains: [Domain]
  public var id: Tagged<Self, UUID>
  public var subscriptionId: Subscription.ID

  public init(
    ciToken: CIToken,
    companyName: String,
    domain: Domain,
    domains: [Domain],
    id: ID,
    subscriptionId: Subscription.ID
  ) {
    self.ciToken = ciToken
    self.companyName = companyName
    self.domain = domain
    self.domains = domains
    self.id = id
    self.subscriptionId = subscriptionId
  }

  public typealias CIToken = Tagged<(Self, ciToken: ()), String>
  public typealias Domain = Tagged<Self, String>
}

public struct EnterpriseEmail: Decodable, Equatable, Identifiable {
  public var id: Tagged<Self, UUID>
  public var email: EmailAddress
  public var userId: User.ID

  public init(id: ID, email: EmailAddress, userId: User.ID) {
    self.id = id
    self.email = email
    self.userId = userId
  }
}

public struct EnterpriseRequestFormData: Codable, Equatable {
  public var email: EmailAddress

  public init(email: EmailAddress) {
    self.email = email
  }

  public enum CodingKeys: String, CodingKey {
    case email
  }
}
