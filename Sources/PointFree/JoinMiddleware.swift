import Models
import Dependencies
import Foundation
import HttpPipeline
import PointFreeRouter

func joinMiddleware(_ conn: Conn<StatusLineOpen, Join>) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database

  switch conn.data {
  case let .code(code):
    do {
      let subscription = try await database.fetchSubscriptionByTeamInviteCode(code)
      let isDomain = code.rawValue.contains(".")
      return conn
        .writeStatus(.ok)
        .respond(text: "Hello: \(code) - \(subscription.stripeSubscriptionId.rawValue)")
    } catch {
      return conn
        .redirect(to: .home) {
          $0.flash(.error, "We could not find that team.")
        }
    }
  }
}
