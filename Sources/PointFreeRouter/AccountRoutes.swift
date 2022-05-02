import Foundation
import Models
import Stripe
import URLRouting

public enum Account: Equatable {
  case confirmEmailChange(payload: Encrypted<String>)
  case index
  case invoices(Invoices = .index)
  case paymentInfo(PaymentInfo = .show)
  case rss(salt: User.RssSalt)
  case rssLegacy(secret1: String, secret2: String)
  case subscription(Subscription)
  case update(ProfileData? = nil)

  public enum Invoices: Equatable {
    case index
    case show(Stripe.Invoice.Id)
  }

  public enum PaymentInfo: Equatable {
    case show
    case update(Stripe.Token.Id? = nil)
  }

  public enum Subscription: Equatable {
    case cancel
    case change(Change = .show)
    case reactivate

    public enum Change: Equatable {
      case show
      case update(Pricing? = nil)
    }
  }
}

let accountRouter = OneOf {
  Route(.case(Account.index))

  Route(.case(Account.confirmEmailChange)) {
    Path { "confirm-email-change" }
    Query {
      Field("payload", .string.representing(Encrypted.self))
    }
  }

  Route(.case(Account.invoices)) {
    Path { "invoices" }

    OneOf {
      Route(.case(Account.Invoices.index))

      Route(.case(Account.Invoices.show)) {
        Path { Parse(.string.representing(Invoice.Id.self)) }
      }
    }
  }

  Route(.case(Account.paymentInfo)) {
    Path { "payment-info" }

    OneOf {
      Route(.case(Account.PaymentInfo.show))

      Route(.case(Account.PaymentInfo.update)) {
        Method.post
        Optionally {
          Body {
            FormData {
              Field("token", .string.representing(Token.Id.self))
            }
          }
        }
      }
    }
  }

  Parse {
    Path { "rss" }

    OneOf {
      Route(.case(Account.rss)) {
        Path { Parse(.string.representing(User.RssSalt.self)) }
      }

      Route(.case(Account.rssLegacy)) {
        Path {
          Parse(.string)
          Parse(.string)
        }
      }
    }
  }

  Route(.case(Account.subscription)) {
    Path { "subscription" }

    OneOf {
      Route(.case(Account.Subscription.cancel)) {
        Method.post
        Path { "cancel" }
      }

      Route(.case(Account.Subscription.change)) {
        Path { "change" }

        OneOf {
          Route(.case(Account.Subscription.Change.show))

          Route(.case(Account.Subscription.Change.update)) {
            Method.post
            Optionally {
              Body(.form(Pricing.self, decoder: formDecoder))
            }
          }
        }
      }

      Route(.case(Account.Subscription.reactivate)) {
        Method.post
        Path { "reactivate" }
      }
    }
  }

  Route(.case(Account.update)) {
    Method.post
    Optionally {
      Body(.form(ProfileData.self, decoder: formDecoder))
    }
  }
}
