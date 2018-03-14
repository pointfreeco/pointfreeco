import ApplicativeRouter
import Optics
import Prelude
import UrlFormEncoding

extension Route {
  public enum Account: DerivePartialIsos {
    case confirmEmailChange(userId: Database.User.Id, emailAddress: EmailAddress)
    case index
    case paymentInfo(PaymentInfo)
    case subscription(Subscription)
    case update(ProfileData?)

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

let tmp: Router<Route> =
  lit("account") %>
    (.account <<< .index <¢> get <% end)
let tmp1: Router<Route> =
    (.account <<< .index <¢> get %> lit("account") %> end)

let accountRouter =
//  lit("account")
    namespace("account") <| accountRouters.reduce(.empty, <|>)


//  accountRouters
//    .map { x in lit("account") %> x }
//    .reduce(.empty, <|>)

private let accountRouters: [Router<Route>] = [

  .account <<< .confirmEmailChange
    <¢> get %> lit("confirm-email-change")
    %> queryParam("payload", .appDecrypted >>> payload(.uuid >>> .tagged, .tagged))
    <% end,

  .account <<< .index
    <¢> get <% end,

  .account <<< .paymentInfo <<< .show
    <¢> get %> lit("payment-info")
    %> queryParam("expand", opt(.bool))
    <% end,

  .account <<< .paymentInfo <<< .update
    <¢> post %> lit("payment-info")
    %> formField("token", Optional.iso.some >>> opt(.string >>> .tagged))
    <% end,

  .account <<< .subscription <<< .cancel
    <¢> post %> lit("subscription") %> lit("cancel") <% end,

  .account <<< .subscription <<< .change <<< .show
    <¢> get %> lit("subscription") %> lit("change") <% end,

  .account <<< .subscription <<< .change <<< .update
    <¢> post %> lit("subscription") %> lit("change")
    %> formBody(Pricing?.self, decoder: formDecoder)
    <% end,

  .account <<< .subscription <<< .reactivate
    <¢> post %> lit("subscription") %> lit("reactivate") <% end,

  .account <<< .update
    <¢> post %> formBody(ProfileData?.self, decoder: formDecoder) <% end,

]

private let formDecoder = UrlFormDecoder()
  |> \.parsingStrategy .~ .bracketsWithIndices
