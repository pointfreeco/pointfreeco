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
  requireUser
    <| { (conn: Conn<StatusLineOpen, Tuple2<Database.User, ProfileData?>>) -> IO<Conn<ResponseEnded, Data>> in
      let (user, data) = lower(conn.data)

      return pure(data)
        .mapExcept(requireSome)
        .flatMap { AppEnvironment.current.database.updateUser(user.id, $0.name, $0.email) }
        .run
        .flatMap(const(conn |> redirect(to: path(to: .account))))
}
