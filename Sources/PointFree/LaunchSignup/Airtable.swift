import Either
import Foundation
import Optics
import Prelude

func createRow(email: EmailAddress)
  -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit> {
    return { baseId in

      let request = URLRequest(url: URL(string: "https://api.airtable.com/v0/\(baseId)/Emails")!)
        |> \.httpMethod .~ "POST"
        |> \.httpBody .~ (try? JSONEncoder().encode(["fields": ["Email": email]]))
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Bearer \(AppEnvironment.current.envVars.airtable.bearer)",
          "Content-Type": "application/json"
      ]

      return dataTask(with: request)
//        .map(tap(AppEnvironment.current.logger.debug) >>> const(unit))
//        .withExcept(tap(AppEnvironment.current.logger.error) >>> const(unit))
        .flatMap { x in lift <| AppEnvironment.current.logger.logIO(.debug, x) }
        .map(const(unit))
//        .catch { x in throwE <| AppEnvironment.current.logger.logIO(.error, x) }
        .withExcept(const(unit))
    }
}
