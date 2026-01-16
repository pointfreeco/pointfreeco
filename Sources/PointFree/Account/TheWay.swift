import Dependencies
import Foundation
import HttpPipeline
import IssueReporting
import Models
import PointFreeRouter

func theWayMiddleware(
  _ conn: Conn<StatusLineOpen, Account.TheWay>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  // TODO: guard with feature flag

  switch conn.data {
  case .login(let redirect, let whoami, let machine):
    do {
      guard
        var redirectBase = URLComponents(string: redirect)
      else {
        return conn.redirect(to: .home) {
          $0.flash(.error, "Could not login.")
        }
      }
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
        return conn.redirect(to: .home) {
          $0.flash(.error, "Could not login.")
        }
      }
      return await conn.redirect(to: redirectString)
    } catch {
      return conn.redirect(to: .home) {
        $0.flash(.error, "Could not login.")
      }
    }

  case .download(let token, let whoami, let machine):
    do {
      let access = try await database.fetchTheWayAccess(machine: machine, whoami: whoami)
      guard access.id == token
      else {
        struct MismatchedToken: Error {}
        throw MismatchedToken()
      }

      @Dependency(\.gitHub) var gitHub
      @Dependency(\.envVars.gitHub.pfwDownloadsAccessToken) var pfwDownloadsAccessToken

      let sha = try await gitHub.fetchBranch(
        owner: "pointfreeco",
        repo: "the-point-free-way",
        branch: "main",
        token: pfwDownloadsAccessToken
      )
      .commit.sha

      let data = try await gitHub.fetchZipball(
        owner: "pointfreeco",
        repo: "the-point-free-way",
        ref: sha.rawValue,
        token: pfwDownloadsAccessToken
      )

      return conn
        .writeStatus(.ok)
        .respond(data: Data("hello!".utf8))
    } catch {
      return conn
        .writeStatus(.unauthorized)
        .respond(text: "Could not download skills.")
    }
  }
}

// TODO: move to HTTP pipeline or somewhere else
extension Conn where Step == HeadersOpen {
  public func respond(data: Data) -> Conn<ResponseEnded, Data> {
    map { _ in data }
      .writeHeader(.contentType(.application(.init(rawValue: "octet-stream"))))
      .writeHeader(.contentLength(data.count))
      .closeHeaders()
      .end()
  }
}
