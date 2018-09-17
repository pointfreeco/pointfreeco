import ApplicativeRouter
import Foundation
import Prelude

public let accountRouter = accountRouters.reduce(.empty, <|>)

extension Route {
  public enum Account: DerivePartialIsos {
    case confirmEmailChange(userId: Database.User.Id, emailAddress: EmailAddress)
    case index
    case invoices(Invoices)
    case paymentInfo(PaymentInfo)
    case rss(payload: String)
    case subscription(Subscription)
    case update(ProfileData?)

    public enum Invoices: DerivePartialIsos {
      case index
      case show(Stripe.Invoice.Id)
    }

    public enum PaymentInfo: DerivePartialIsos {
      case show(expand: Bool?)
      case update(Stripe.Token.Id?)
    }

    public enum Subscription: DerivePartialIsos {
      case cancel
      case change(Change)
      case reactivate

      public enum Change: DerivePartialIsos {
        case show
        case update(Pricing?)
      }
    }
  }
}

private let accountRouters: [Router<Route.Account>] = [

  .confirmEmailChange
    <¢> get %> lit("confirm-email-change")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .tagged))
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
    <¢> get %> lit("rss") %> .string <% end,

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

extension PartialIso where A == String, B == (Database.User.Id, Database.User.RssSalt) {

  static 
}
