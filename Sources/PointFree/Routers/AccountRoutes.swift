import ApplicativeRouter
import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Styleguide
import Tuple

public let accountRouter = accountRouters.reduce(.empty, <|>)

extension Route {
  public enum Account: DerivePartialIsos, Equatable {
    case confirmEmailChange(userId: Database.User.Id, emailAddress: EmailAddress)
    case index
    case invoices(Invoices)
    case paymentInfo(PaymentInfo)
    case rss(userId: Database.User.Id, rssSalt: Database.User.RssSalt)
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
    <¢> (get <|> head) %> lit("rss")
    %> pathParam(.appDecrypted >>> .uuid >>> .tagged)
    <%> pathParam(.appDecrypted >>> .uuid >>> .tagged)
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

func renderAccount(conn: Conn<StatusLineOpen, Tuple4<Database.Subscription?, Database.User?, SubscriberState, Route.Account>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (_, user, subscriberState, account) = lower(conn.data)

    switch account {
    case let .confirmEmailChange(userId, emailAddress):
      return conn.map(const(userId .*. emailAddress .*. unit))
        |> confirmEmailChangeMiddleware

    case .index:
      return conn.map(const(user .*. subscriberState .*. unit))
        |> accountResponse

    case .invoices(.index):
      return conn.map(const(user .*. subscriberState .*. unit))
        |> invoicesResponse

    case let .invoices(.show(invoiceId)):
      return conn.map(const(user .*. invoiceId .*. unit))
        |> invoiceResponse

    case let .paymentInfo(.show(expand)):
      return conn.map(const(user .*. (expand == .some(true) ? .full : .minimal) .*. subscriberState .*. unit))
        |> paymentInfoResponse

    case let .paymentInfo(.update(token)):
      return conn.map(const(user .*. token .*. unit))
        |> updatePaymentInfoMiddleware

    case let .rss(userId, rssSalt):
      return conn.map(const(userId .*. rssSalt .*. unit))
        |> accountRssMiddleware

    case .subscription(.cancel):
      return conn.map(const(user .*. unit))
        |> cancelMiddleware

    case .subscription(.change(.show)):
      return conn.map(const(user .*. subscriberState .*. unit))
        |> subscriptionChangeShowResponse

    case let .subscription(.change(.update(pricing))):
      return conn.map(const(user .*. pricing .*. unit))
        |> subscriptionChangeMiddleware

    case .subscription(.reactivate):
      return conn.map(const(user .*. unit))
        |> reactivateMiddleware

    case let .update(data):
      return conn.map(const(user .*. data .*. unit))
        |> updateProfileMiddleware
    }
}
