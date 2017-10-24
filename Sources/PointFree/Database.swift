import Either
import PostgreSQL
import Prelude

public struct User {
  let email: String
  let gitHubUserId: Int
  let gitHubAccessToken: String
  let id: Int
  let name: String
}

private let postgres = EitherIO.init <<< IO.wrap(Either.wrap(Database.init)) <| ConnInfo.basic(
  hostname: EnvVars.PostgreSQL.hostname,
  port: EnvVars.PostgreSQL.port,
  database: EnvVars.PostgreSQL.database,
  user: EnvVars.PostgreSQL.user,
  password: EnvVars.PostgreSQL.password
)

private let conn: EitherIO<Error, Connection> = postgres
  .flatMap { db in .wrap(db.makeConnection) }

public func execute(_ query: String, _ representable: [NodeRepresentable]) -> EitherIO<Error, Node> {
  return conn.flatMap { conn in
    .wrap { try conn.execute(query, representable) }
  }
}

public func createUser(from envelope: GitHubUserEnvelope) -> EitherIO<Error, Unit> {
  return execute(
    """
    INSERT INTO "users" ("email", "github_user_id", "github_access_token", "name")
    VALUES ($1, $2, $3, $4)
    """,
    [
      envelope.gitHubUser.email,
      envelope.gitHubUser.id,
      envelope.accessToken.accessToken,
      envelope.gitHubUser.name,
      ]
    )
    .map(const(unit))
}

public func fetchUser(from token: GitHubAccessToken) -> EitherIO<Error, User?> {
  return execute(
    """
    SELECT "email", "github_user_id", "github_access_token", "id", "name"
    FROM "users"
    WHERE "github_token" = $1
    LIMIT 1
    """,
    [token.accessToken]
    )
    .map { result in
      return curry(User.init)
        <¢> result[0, "email"]?.string
        <*> result[1, "github_user_id"]?.int
        <*> result[2, "github_access_token"]?.string
        <*> result[3, "id"]?.int
        <*> result[4, "name"]?.string
  }
}
