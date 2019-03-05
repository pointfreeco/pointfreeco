import ApplicativeRouter
import Models
import PointFreePrelude
import Prelude
import Stripe

public enum Account: DerivePartialIsos, Equatable {
  case confirmEmailChange(userId: User.Id, emailAddress: EmailAddress)
  case index
  case invoices(Invoices)
  case paymentInfo(PaymentInfo)
  case rss(userId: User.Id, rssSalt: User.RssSalt)
  case subscription(Subscription)
  case update(ProfileData?)

  public enum Invoices: DerivePartialIsos, Equatable {
    case index
    case show(Stripe.Invoice.Id)
  }

  public enum PaymentInfo: DerivePartialIsos, Equatable {
    case show(expand: Bool?)
    case update(Stripe.Token.Id?)
  }

  public enum Subscription: DerivePartialIsos, Equatable {
    case cancel
    case change(Change)
    case reactivate

    public enum Change: DerivePartialIsos, Equatable {
      case show
      case update(Pricing?)
    }
  }
}

public func accountRouter(appSecret: String) -> Router<Account> {
  return accountRouters(appSecret: appSecret).reduce(.empty, <|>)
}

private func accountRouters(appSecret: String) -> [Router<Account>] {
  return [
    .confirmEmailChange
      <¢> get %> lit("confirm-email-change")
      %> queryParam("payload", .decrypted(withSecret: appSecret) >>> payload(.tagged(.uuid), .tagged))
      <% end,

    .index
      <¢> get <% end,

    .invoices <<< .index
      <¢> get %> lit("invoices") <% end,

    .invoices <<< .show
      <¢> get %> lit("invoices") %> pathParam(.tagged(.string)) <% end,

    .paymentInfo <<< .show
      <¢> get %> lit("payment-info")
      %> queryParam("expand", opt(.bool))
      <% end,

    .paymentInfo <<< .update
      <¢> post %> lit("payment-info")
      %> formField("token", Optional.iso.some >>> opt(.tagged(.string)))
      <% end,

    .rss
      <¢> (get <|> head) %> lit("rss")
      %> pathParam(.decrypted(withSecret: appSecret) >>> .tagged(.uuid))
      <%> pathParam(.decrypted(withSecret: appSecret) >>> .tagged(.uuid))
      <% end,

    .subscription <<< .cancel
      <¢> post %> lit("subscription") %> lit("cancel") <% end,

    .subscription <<< .change <<< .show
      <¢> get %> lit("subscription") %> lit("change") <% end,

    .subscription <<< .change <<< .update
      <¢> post %> lit("subscription") %> lit("change")
      %> formBody(Pricing?.self, decoder: formDecoder)
      <% end,

    .subscription <<< .reactivate
      <¢> post %> lit("subscription") %> lit("reactivate") <% end,

    .update
      <¢> post %> formBody(ProfileData?.self, decoder: formDecoder) <% end,
    ]
}
