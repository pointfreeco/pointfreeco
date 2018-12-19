import Either
import Foundation
import HttpPipeline
import Prelude
import Tuple

// NB: remove this `Encodable` to get a runtime crash
public struct ProfileData: Encodable, Equatable {
  public let email: EmailAddress
  public let extraInvoiceInfo: String?
  public let emailSettings: [String: String]
  public let name: String?

  public enum CodingKeys: String, CodingKey {
    case email
    case extraInvoiceInfo
    case emailSettings
    case name
  }
}

extension ProfileData: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.email = try container.decode(EmailAddress.self, forKey: .email)
    self.emailSettings = (try? container.decode([String: String].self, forKey: .emailSettings)) ?? [:]
    self.extraInvoiceInfo = try? container.decode(String.self, forKey: .extraInvoiceInfo)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
  }
}

func isValidEmail(_ email: EmailAddress) -> Bool {
  return email.rawValue.range(of: "^.+@.+$", options: .regularExpression) != nil
}

private func fetchStripeSubscription<A>(
  _ middleware: (@escaping Middleware<StatusLineOpen, ResponseEnded, T2<Stripe.Subscription?, A>, Data>)
  )
  -> Middleware<StatusLineOpen, ResponseEnded, T2<Database.Subscription?, A>, Data> {

    return { conn -> IO<Conn<ResponseEnded, Data>> in
      guard let subscription = get1(conn.data)
        else { return middleware(conn.map(over1(const(nil)))) }

      return Current.stripe.fetchSubscription(subscription.stripeSubscriptionId)
        .run
        .map(^\.right)
        .flatMap { conn.map(const($0 .*. conn.data.second)) |> middleware }
    }
}

let updateProfileMiddleware =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< filterMap(require2 >>> pure, or: redirect(to: .account(.index)))
    <<< filter(
      get2 >>> ^\.email >>> isValidEmail,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Please enter a valid email."))
    )
    <<< fetchSubscription
    <<< fetchStripeSubscription
    <| { (conn: Conn<StatusLineOpen, Tuple3<Stripe.Subscription?, Database.User, ProfileData>>) -> IO<Conn<ResponseEnded, Data>> in
      let (subscription, user, data) = lower(conn.data)

      let emailSettings = data.emailSettings.keys
        .compactMap(Database.EmailSetting.Newsletter.init(rawValue:))

      let updateFlash: Middleware<HeadersOpen, HeadersOpen, Prelude.Unit, Prelude.Unit>
      if data.email.rawValue.lowercased() != user.email.rawValue.lowercased() {
        updateFlash = flash(.warning, "We’ve sent an email to \(user.email) to confirm this change.")
        parallel(
          sendEmail(
            to: [user.email],
            subject: "Email change confirmation",
            content: inj2(confirmEmailChangeEmailView.view((user, data.email)))
            )
            .run
          )
          .run({ _ in })
      } else {
        updateFlash = flash(.notice, "We’ve updated your profile!")
      }

      let updateCustomerExtraInvoiceInfo = zip2(
        subscription?.customer.left ?? subscription?.customer.right?.id,
        data.extraInvoiceInfo
        )
        .map(Current.stripe.updateCustomerExtraInvoiceInfo >>> map(const(unit)))
        ?? pure(unit)

      return Current.database.updateUser(user.id, data.name, nil, emailSettings, nil)
        .flatMap(const(updateCustomerExtraInvoiceInfo))
        .run
        .flatMap(
          const(
            conn.map(const(unit))
              |> redirect(to: path(to: .account(.index)), headersMiddleware: updateFlash)
          )
      )
}

let confirmEmailChangeMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, EmailAddress>, Data> = { conn in
  let (userId, newEmailAddress) = lower(conn.data)

  parallel(
    Current.database.fetchUserById(userId)
      .bimap(const(unit), id)
      .flatMap { user in
        sendEmail(
          to: [newEmailAddress],
          subject: "Email change confirmation",
          content: inj2(emailChangedEmailView.view((user, newEmailAddress)))
        )
      }
      .run
    )
    .run({ _ in })

  return Current.database.updateUser(userId, nil, newEmailAddress, nil, nil)
    .run
    .flatMap(const(conn |> redirect(to: .account(.index))))
}
