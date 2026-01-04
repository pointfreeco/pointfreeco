import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter

func theWayMiddleware(
  _ conn: Conn<StatusLineOpen, Account.TheWay>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database

  switch conn.data {
  case .login(let redirect, let whoami, let machine):
    guard
      var redirectBase = URLComponents(string: redirect)
    else {
      return conn.redirect(to: .home) {
        $0.flash(.error, "Could not login.")
      }
    }
    do {
      let access = try await database.upsertTheWayAccess(
        TheWayAccess(
          id: TheWayAccess.ID(),
          machine: machine,
          whoami: whoami,
          createdAt: Date(),
          updatedAt: nil
        )
      )
      redirectBase.queryItems = [
        URLQueryItem(name: "token", value: access.id.rawValue.uuidString)
      ]
      guard let redirectString = redirectBase.url?.absoluteString
      else {
        fatalError()
      }
      return await conn.redirect(to: redirectString)
    } catch {
      return conn.redirect(to: .home) {
        $0.flash(.error, "Could not login.")
      }
    }

  case .download(let token, let whoami, let machine):
    fatalError()
  }
}
