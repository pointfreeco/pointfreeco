import ApplicativeRouter
import Models
import PointFreePrelude
import Prelude
import Stripe

public enum Account: Equatable {
  case confirmEmailChange(payload: Encrypted<String>)
  case index
  case invoices
  case paymentInfo(PaymentInfo)
  case rss(userId: Encrypted<String>, rssSalt: Encrypted<String>)
  case subscription(Subscription)
  case update(ProfileData?)

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

let accountRouter
  = accountRouters.reduce(.empty, <|>)

private let accountRouters: [Router<Account>] = [
  .case(Account.confirmEmailChange)
    <¢> get %> lit("confirm-email-change")
    %> queryParam("payload", .tagged)
    <% end,

  .case(const(.index))
    <¢> get <% end,

  .case(const(.invoices))
    <¢> get %> lit("invoices") <% end,

  .case(const(.paymentInfo(.show)))
    <¢> get %> lit("payment-info") <% end,

  .case { .paymentInfo(.update($0)) }
    <¢> post %> lit("payment-info")
    %> formField("token", Optional.iso.some >>> opt(.tagged(.string)))
    <% end,

  .case(Account.rss)
    <¢> (get <|> head) %> lit("rss")
    %> pathParam(.tagged)
    <%> pathParam(.tagged)
    <% end,

  .case(const(.subscription(.cancel)))
    <¢> post %> lit("subscription") %> lit("cancel") <% end,

  .case(const(.subscription(.change(.show))))
    <¢> get %> lit("subscription") %> lit("change") <% end,

  .case { .subscription(.change(.update($0))) }
    <¢> post %> lit("subscription") %> lit("change")
    %> formBody(Pricing?.self, decoder: formDecoder)
    <% end,

  .case(const(.subscription(.reactivate)))
    <¢> post %> lit("subscription") %> lit("reactivate") <% end,

  .case(Account.update)
    <¢> post %> formBody(ProfileData?.self, decoder: formDecoder) <% end,
]
