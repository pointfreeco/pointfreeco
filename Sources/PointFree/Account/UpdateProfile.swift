import Either
import Foundation
import HttpPipeline
import Prelude
import Tuple

// NB: change this `Codable` to `Decodable` to get a runtime crash
public struct ProfileData: Codable {
  public let email: EmailAddress
  public let name: String
  public let emailSettings: [String: String]

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.email = try container.decode(EmailAddress.self, forKey: .email)
    self.name = try container.decode(String.self, forKey: .name)
    self.emailSettings = (try? container.decode([String: String].self, forKey: .emailSettings)) ?? [:]
  }

  public enum CodingKeys: String, CodingKey {
    case email
    case name
    case emailSettings
  }
}

let updateProfileMiddleware =
  filterMap(require2, or: loginAndRedirect)
    <| { (conn: Conn<StatusLineOpen, Tuple2<ProfileData?, Database.User>>) -> IO<Conn<ResponseEnded, Data>> in
      let (data, user) = lower(conn.data)

      let emailSettings = Array((data?.emailSettings ?? [:]).keys)
        .flatMap(Database.EmailSetting.Newsletter.init(rawValue:))

      if data?.email.unwrap != .some(user.email.unwrap) {
        // TODO: confirm email change
      }

      return pure(data)
        .mapExcept(requireSome)
        .flatMap { AppEnvironment.current.database.updateUser(user.id, $0.name, $0.email, emailSettings) }
        .run
        .flatMap(const(conn |> redirect(to: path(to: .account))))
}

//let confirm

