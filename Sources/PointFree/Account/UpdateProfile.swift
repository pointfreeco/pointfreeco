import Either
import Foundation
import HttpPipeline
import Prelude
import Tuple

// NB: remove this `Encodable` to get a runtime crash
public struct ProfileData: Encodable {
  public let email: EmailAddress
  public let name: String?
  public let emailSettings: [String: String]

  public enum CodingKeys: String, CodingKey {
    case email
    case name
    case emailSettings
  }
}

extension ProfileData: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.email = try container.decode(EmailAddress.self, forKey: .email)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.emailSettings = (try? container.decode([String: String].self, forKey: .emailSettings)) ?? [:]
  }
}

func isValidEmail(_ email: EmailAddress) -> Bool {
  return email.rawValue.range(of: "^.+@.+$", options: .regularExpression) != nil
}

let updateProfileMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <<< filterMap(require1 >>> pure, or: redirect(to: .account(.index)))
    <<< filter(
      get1 >>> ^\.email >>> isValidEmail,
      or: redirect(to: .account(.index), headersMiddleware: flash(.error, "Please enter a valid email."))
    )
    <| { (conn: Conn<StatusLineOpen, Tuple2<ProfileData, Database.User>>) -> IO<Conn<ResponseEnded, Data>> in
      let (data, user) = lower(conn.data)

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

      return Current.database.updateUser(user.id, data.name, nil, emailSettings, nil)
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
