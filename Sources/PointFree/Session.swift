//import Foundation
//import HttpPipeline
//import Prelude
//import Tuple
//
//public struct Session: Codable {
//  let userId: Database.User.Id?
//  let flash: Flash?
//
//  private enum CodingKeys: String, CodingKey {
//    case userId = "user_id"
//    case flash
//  }
//}
//
//public func readSessionCookieMiddleware<I, A>(
//  _ conn: Conn<I, A>)
//  -> IO<Conn<I, T2<Session, A>>> {
//
//    let session = conn.request.cookies[pointFreeUserSession]
//      .flatMap {
//        Response.Header
//          .verifiedString(signedCookieValue: $0, secret: AppEnvironment.current.envVars.appSecret)
//      }
//      .flatMap { try? jsonDecoder.decode(Session.self, from: Data($0.utf8)) }
//      ?? pure(Session(userId: nil, flash: nil))
//
//    return session
//      .map { conn.map(const($0 .*. conn.data)) }
//}
//
//private func writeSessionCookieMiddleware(
//  _ conn: Conn<HeadersOpen, Database.User>
//  )
//  -> IO<Conn<HeadersOpen, Database.User>> {
//
//    return conn |> writeHeaders(
//      [
//        Response.Header.setSignedCookie(
//          key: pointFreeUserSession,
//          value: conn.data.id.unwrap.uuidString,
//          options: [],
//          secret: AppEnvironment.current.envVars.appSecret,
//          encrypt: true
//        )
//        ]
//        |> catOptionals
//    )
//}
//
//private let jsonDecoder = JSONDecoder()
//private let jsonEncoder = JSONEncoder()
//private let pointFreeUserSession = "pf_session"

