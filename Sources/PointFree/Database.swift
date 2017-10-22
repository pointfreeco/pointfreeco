import Either
import PostgreSQL
import Prelude

let postgreSQL = IO.wrap(Either.wrap(Database.init)) >>> EitherIO.init

public func save(user: GitHubUser) -> EitherIO<Unit, Unit> {
  postgreSQL(ConnInfo.basic(hostname: <#T##String#>, port: <#T##Int#>, database: <#T##String#>, user: <#T##String#>, password: <#T##String#>))

//  postgreSQL.makeConnection()
  fatalError()
}
