import ApplicativeRouter
import Models
import PointFreePrelude
import Prelude
import Stripe

public enum Account: Equatable {
  case confirmEmailChange(payload: Encrypted<String>)
  case index
  case invoices(Invoices)
  case paymentInfo(PaymentInfo)
  case rss(userId: Encrypted<String>, rssSalt: Encrypted<String>)
  case subscription(Subscription)
  case update(ProfileData?)

  public enum Invoices: Equatable {
    case index
    case show(Stripe.Invoice.Id)
  }

  public enum PaymentInfo: Equatable {
    case show
    case update(Stripe.Token.Id?)
  }

  public enum Subscription: Equatable {
    case cancel
    case change(Change)
    case reactivate

    public enum Change: Equatable {
      case show
      case update(Pricing?)
    }
  }
}

let accountRouter = accountRouters.reduce(.empty, <|>)

private let accountRouters: [Router<Account>] = [
  .case(Account.confirmEmailChange)
    <¢> get %> "confirm-email-change"
    %> queryParam("payload", .tagged)
    <% end,

  .case(.index)
    <¢> get <% end,

  .case(.invoices(.index))
    <¢> get %> "invoices" <% end,

  .case { .invoices(.show($0)) }
    <¢> get %> "invoices" %> pathParam(.tagged(.string)) <% end,

  .case(.paymentInfo(.show))
    <¢> get %> "payment-info" <% end,

  .case { .paymentInfo(.update($0)) }
    <¢> post %> "payment-info"
    %> formField("token", Optional.iso.some >>> opt(.tagged(.string)))
    <% end,

  .case(Account.rss)
    <¢> (get <|> head) %> "rss"
    %> pathParam(.tagged)
    <%> pathParam(.tagged)
    <% end,

  .case(.subscription(.cancel))
    <¢> post %> "subscription" %> "cancel" <% end,

  .case(.subscription(.change(.show)))
    <¢> get %> "subscription" %> "change" <% end,

  .case { .subscription(.change(.update($0))) }
    <¢> post %> "subscription" %> "change"
    %> formBody(Pricing?.self, decoder: formDecoder)
    <% end,

  .case(.subscription(.reactivate))
    <¢> post %> "subscription" %> "reactivate" <% end,

  .case(Account.update)
    <¢> post %> formBody(ProfileData?.self, decoder: formDecoder) <% end,
]
