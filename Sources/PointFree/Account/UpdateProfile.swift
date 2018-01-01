import Either
import Foundation
import HttpPipeline
import Prelude
import Tuple

// NB: remove this `Encodable` to get a runtime crash
public struct ProfileData: Encodable {
  public let email: EmailAddress
  public let name: String
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
    self.name = try container.decode(String.self, forKey: .name)
    self.emailSettings = (try? container.decode([String: String].self, forKey: .emailSettings)) ?? [:]
  }
}

let updateProfileMiddleware =
  filterMap(require1 >>> pure, or: redirect(to: .account(.index)))
    <<< filterMap(require2 >>> pure, or: loginAndRedirect)
    <| { (conn: Conn<StatusLineOpen, Tuple2<ProfileData, Database.User>>) -> IO<Conn<ResponseEnded, Data>> in
      let (data, user) = lower(conn.data)

      let emailSettings = data.emailSettings.keys
        .flatMap(Database.EmailSetting.Newsletter.init(rawValue:))

      // TODO: make sure email doesn't already exist?!
      // TODO: validate email?

      let updateFlash: Middleware<HeadersOpen, HeadersOpen, Prelude.Unit, Prelude.Unit>
      if data.email.unwrap.lowercased() != user.email.unwrap.lowercased() {
        updateFlash = flash(.warning, "We’ve sent an email to \(data.email.unwrap) to confirm this change.")
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

      return AppEnvironment.current.database.updateUser(user.id, data.name, nil, emailSettings)
        .run
        .flatMap(
          const(
            conn.map(const(unit))
              |> redirect(to: path(to: .account(.index)), headersMiddleware: updateFlash)
          )
      )
}


let confirmEmailChangeMiddleware =
{ (conn: Conn<StatusLineOpen, Tuple2<Database.User.Id, EmailAddress>>) -> IO<Conn<ResponseEnded, Data>> in
  let (userId, emailAddress) = lower(conn.data)

  // TODO: confirm that currentUser.id == userId
  // TODO: send email saying that email has been changed

  return AppEnvironment.current.database.updateUser(userId, nil, emailAddress, nil)
    .run
    .flatMap(const(conn |> redirect(to: .account(.index))))
}
