import ApplicativeRouter
import Foundation
import Models
import PointFreePrelude
import Parsing
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

let accountRouter = OneOf {
  Routing(/Account.index) {
    Method.get
  }

  Routing(/Account.confirmEmailChange) {
    Method.get
    Path { "confirm-email-change" }
    Query {
      Field("payload", Encrypted.parser(rawValue: String.parser()))
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
        Path { Invoice.Id.parser(rawValue: String.parser()) }
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
        Optionally {
          Body {
            FormData {
              Field("token", Token.Id.parser(rawValue: String.parser()))
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
        Path { User.RssSalt.parser(rawValue: String.parser()) }
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
