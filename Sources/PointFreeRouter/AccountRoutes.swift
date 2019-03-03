import ApplicativeRouter
import Models
import PointFreePrelude
import Prelude
import Stripe

public enum Account: DerivePartialIsos, Equatable {
  case confirmEmailChange(payload: Encrypted<String>)
  case index
  case invoices(Invoices)
  case paymentInfo(PaymentInfo)
  case rss(userId: Encrypted<String>, rssSalt: Encrypted<String>)
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

public let accountRouter
  = accountRouters.reduce(.empty, <|>)

private let accountRouters: [Router<Account>] = [
  .confirmEmailChange
    <¢> get %> lit("confirm-email-change")
    %> queryParam("payload", .tagged)
    <% end,

  .index
    <¢> get <% end,

  .invoices <<< .index
    <¢> get %> lit("invoices") <% end,

  .invoices <<< .show
    <¢> get %> lit("invoices") %> pathParam(.string >>> .tagged) <% end,

  .paymentInfo <<< .show
    <¢> get %> lit("payment-info")
    %> queryParam("expand", opt(.bool))
    <% end,

  .paymentInfo <<< .update
    <¢> post %> lit("payment-info")
    %> formField("token", Optional.iso.some >>> opt(.string >>> .tagged))
    <% end,

  .rss
    <¢> (get <|> head) %> lit("rss")
    %> pathParam(.tagged)
    <%> pathParam(.tagged)
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
