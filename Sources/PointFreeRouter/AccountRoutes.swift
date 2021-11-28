import ApplicativeRouter
import Foundation
import Models
import PointFreePrelude
import Prelude
import Stripe
import URLRouting

public enum Account: Equatable {
  case confirmEmailChange(payload: Encrypted<String>)
  case index
  case invoices(Invoices)
  case paymentInfo(PaymentInfo)
  case rss(salt: User.RssSalt)
  case rssLegacy(secret1: String, secret2: String)
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

let accountRouter
  = accountRouters.reduce(.empty, <|>)

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
    <% end,

  .case(Account.rssLegacy)
    <¢> (get <|> head) %> "rss"
    %> pathParam(.id)
    <%> pathParam(.id)
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

private let _accountRouter = OneOf {
  Routing(/Account.index) {
    Method.get
  }

  Routing(/Account.confirmEmailChange) {
    Method.get
    Path { "confirm-email-change" }
    Query {
      Field("payload", String.parser().pipe { Encrypted<String>.parser() })
    }
  }

  Routing(/Account.invoices) {
    Path { "invoices" }

    OneOf {
      Routing(/Account.Invoices.index) {
        Method.get
      }

      Routing(/Account.Invoices.show) {
        Method.get
        Path {
          String.parser().pipe { Stripe.Invoice.Id.parser() }
        }
      }
    }
  }

  Routing(/Account.paymentInfo) {
    Path { "payment-info" }

    OneOf {
      Routing(/Account.PaymentInfo.show) {
        Method.get
      }

      Routing(/Account.PaymentInfo.update) {
        Method.post
        Body {
          FormData {
            Optionally {
              Field("token", String.parser().pipe { Stripe.Token.Id.parser() })
            }
          }
        }
      }
    }
  }

  Parse {
    Path { "rss" }

    OneOf {
      Routing(/Account.rss) {
        Method.get
        Path { String.parser().pipe { User.RssSalt.parser() } }
      }

      Routing(/Account.rssLegacy) {
        Method.get
        Path {
          String.parser()
          String.parser()
        }
      }
    }
  }

  Routing(/Account.subscription) {
    Path { "subscription" }

    OneOf {
      Routing(/Account.Subscription.cancel) {
        Method.post
        Path { "cancel" }
      }

      Routing(/Account.Subscription.change) {
        Path { "change" }

        OneOf {
          Routing(/Account.Subscription.Change.show) {
            Method.get
          }

          Routing(/Account.Subscription.Change.update) {
            Method.post
            Body {
              FormCoded(Pricing?.self, decoder: formDecoder)
            }
          }
        }
      }

      Routing(/Account.Subscription.reactivate) {
        Method.post
        Path { "reactivate" }
      }
    }
  }

  Routing(/Account.update) {
    Method.post
    Body {
      FormCoded(ProfileData?.self, decoder: formDecoder)
    }
  }
}
