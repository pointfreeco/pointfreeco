import Either
import Foundation
import Optics
import Prelude

func createRow(email: String)
  -> (_ baseId: String)
  -> EitherIO<Prelude.Unit, Prelude.Unit> {
    return { baseId in

      let request = URLRequest(url: URL(string: "https://api.airtable.com/v0/\(baseId)/Emails")!)
        |> \.httpMethod .~ "POST"
        |> \.httpBody .~ (try? JSONEncoder().encode(["fields": ["Email": email]]))
        |> \.allHTTPHeaderFields .~ [
          "Authorization": "Bearer \(EnvVars.airtableBearer)",
          "Content-Type": "application/json"
      ]

      return .init(
        run: .init { callback in
          URLSession(configuration: .default)
            .dataTask(with: request) { data, response, error in
              callback(error == nil ? .right(unit) : .left(unit))
            }
            .resume()
        }
      )
    }
}

func mockCreateRow(result: Either<Prelude.Unit, Prelude.Unit>) -> AirtableCreateRow {
  return { email in
    return { baseId in
      return .init(
        run: .init { callback in
          callback(result)
        }
      )
    }
  }
}
