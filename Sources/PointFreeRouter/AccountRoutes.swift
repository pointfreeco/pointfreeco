import CasePaths
import Foundation
import GitHub
import Models
import Stripe
import URLRouting

@CasePathable
public enum Account: Equatable {
  case confirmEmailChange(payload: Encrypted<String>)
  case index
  case invoices(Invoices = .index)
  case paymentInfo(PaymentInfo = .show)
  case regenerateTeamInviteCode
  case rss(salt: User.RssSalt)
  case rssLegacy(secret1: String, secret2: String)
  case subscription(Subscription)
  case theWay(TheWay)
  case update(ProfileData? = nil)

  @CasePathable
  public enum Invoices: Equatable {
    case index
    case show(Stripe.Invoice.ID)
  }

  @CasePathable
  public enum PaymentInfo: Equatable {
    case show
    case update(Stripe.PaymentMethod.ID? = nil)
  }

  @CasePathable
  public enum Subscription: Equatable {
    case cancel
    case change(Change = .show)
    case reactivate

    @CasePathable
    public enum Change: Equatable {
      case show
      case update(Pricing? = nil)
    }
  }

  @CasePathable
  public enum TheWay: Equatable {
    case login(redirect: String, whoami: String, machine: UUID)
    case download(
      token: TheWayAccess.ID,
      whoami: String,
      machine: UUID,
      etag: String?,
      version: String?
    )
  }
}

struct AccountRouter: ParserPrinter {
  var body: some Router<Account> {
    OneOf(output: Account.self) {
      Route(.case(\.index))

      Route(.case(\.confirmEmailChange)) {
        Path { "confirm-email-change" }
        Query {
          Field("payload", .string.representing(Encrypted.self))
        }
      }

      Route(.case(\.invoices)) {
        Path { "invoices" }

        OneOf(output: Account.Invoices.self) {
          Route(.case(\.index))

          Route(.case(\.show)) {
            Path { Parse(.string.representing(Invoice.ID.self)) }
          }
        }
      }

      Route(.case(\.paymentInfo)) {
        Path { "payment-info" }

        OneOf(output: Account.PaymentInfo.self) {
          Route(.case(\.show))

          Route(.case(\.update)) {
            Method.post
            Optionally {
              Body {
                FormData {
                  Field("paymentMethodID", .string.representing(PaymentMethod.ID.self))
                }
              }
            }
          }
        }
      }

      Route(.case(\.regenerateTeamInviteCode)) {
        Method.post
        Path { "regenerate-team-invite-code" }
      }

      Parse {
        Path { "rss" }

        OneOf(output: Account.self) {
          Route(.case(\.rss)) {
            Path { Parse(.string.representing(User.RssSalt.self)) }
          }

          Route(.case(\.rssLegacy)) {
            Path {
              Parse(.string)
              Parse(.string)
            }
          }
        }
      }

      Route(.case(\.subscription)) {
        Path { "subscription" }

        OneOf(output: Account.Subscription.self) {
          Route(.case(\.cancel)) {
            Method.post
            Path { "cancel" }
          }

          Route(.case(\.change)) {
            Path { "change" }

            OneOf(output: Account.Subscription.Change.self) {
              Route(.case(\.show))

              Route(.case(\.update)) {
                Method.post
                Optionally {
                  Body(.form(Pricing.self, decoder: formDecoder))
                }
              }
            }
          }

          Route(.case(\.reactivate)) {
            Method.post
            Path { "reactivate" }
          }
        }
      }

      Route(.case(\.theWay)) {
        Path { "the-way" }
        OneOf(output: Account.TheWay.self) {
          Route(.case(\.login)) {
            Path { "login" }
            Query {
              Field("redirect", .string)
              Field("whoami", .string)
              Field("machine") { UUID.parser() }
            }
          }
          Route(.case(\.download)) {
            Path { "download" }
            Query {
              Field("token") { UUID.parser().map(.representing(TheWayAccess.ID.self)) }
            }
            Query {
              Field("whoami", .string)
            }
            Query {
              Field("machine") { UUID.parser() }
            }
            Headers {
              Optionally { Field("If-None-Match", .string) }
            }
            Headers {
              Optionally { Field("X-PFW-Version", .string) }
            }
          }
        }
      }

      Route(.case(\.update)) {
        Method.post
        Optionally {
          Body(.form(ProfileData.self, decoder: formDecoder))
        }
      }
    }
  }
}
