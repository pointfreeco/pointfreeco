import Either
import Foundation
import HttpPipeline
import Prelude
import Tuple

public struct ProfileData: Codable {
  public let email: EmailAddress
  public let name: String
}

let updateProfileMiddleware =
  filterMap(require2 >>> pure, or: loginAndRedirect)
    <| { (conn: Conn<StatusLineOpen, Tuple2<ProfileData?, Database.User>>) -> IO<Conn<ResponseEnded, Data>> in
      let (data, user) = lower(conn.data)

      return pure(data)
        .mapExcept(requireSome)
        .flatMap { AppEnvironment.current.database.updateUser(user.id, $0.name, $0.email) }
        .run
        .flatMap(
          const(
            conn |> redirect(
              to: path(to: .account),
              headersMiddleware: flash(.notice, "We’ve updated your profile!")
            )
        )
      )
}
