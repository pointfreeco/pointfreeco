import CasePaths
import Foundation
import Models
import PointFreePrelude
import Parsing
import Prelude
import Stripe
import _URLRouting

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

let accountRouter = OneOf {
  Route(/Account.index)

  Route(/Account.confirmEmailChange) {
    Path { "confirm-email-change" }
    Query {
      Field("payload", .string.representing(Encrypted.self))
    }
  }

  Route(/Account.invoices) {
    Path { "invoices" }

    OneOf {
      Route(/Account.Invoices.index)

      Route(/Account.Invoices.show) {
        Path { Parse(.string.representing(Invoice.Id.self)) }
      }
    }
  }

  Route(/Account.paymentInfo) {
    Path { "payment-info" }

    OneOf {
      Route(/Account.PaymentInfo.show)

      Route(/Account.PaymentInfo.update) {
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
      Route(/Account.rss) {
        Path { Parse(.string.representing(User.RssSalt.self)) }
      }

      Route(/Account.rssLegacy) {
        Path {
          Parse(.string)
          Parse(.string)
        }
      }
    }
  }

  Route(/Account.subscription) {
    Path { "subscription" }

    OneOf {
      Route(/Account.Subscription.cancel) {
        Method.post
        Path { "cancel" }
      }

      Route(/Account.Subscription.change) {
        Path { "change" }

        OneOf {
          Route(/Account.Subscription.Change.show)

          Route(/Account.Subscription.Change.update) {
            Method.post
            Optionally {
              Body(.data.form(Pricing.self, decoder: formDecoder))
            }
          }
        }
      }

      Route(/Account.Subscription.reactivate) {
        Method.post
        Path { "reactivate" }
      }
    }
  }

  Route(/Account.update) {
    Method.post
    Optionally {
      Body(.data.form(ProfileData.self, decoder: formDecoder))
    }
  }
}
