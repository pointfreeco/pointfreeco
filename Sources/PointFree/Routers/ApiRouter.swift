import ApplicativeRouter
import ApplicativeRouterHttpPipelineSupport
import Either
import Foundation
import HttpPipeline
import Optics
import Prelude
import Styleguide
import Tuple

public let apiRouter = apiRouters.reduce(.empty, <|>)

extension Route {
  public enum Api: DerivePartialIsos {
    case account
    case auth(String?)
  }
}

private let apiRouters: [Router<Route.Api>] = [

  .account
    <¢> get %> "account" <% end,

  .auth
    <¢> post %> "auth"
    %> formField("token", Optional.iso.some >>> opt(.string))
    <% end,

]

func renderApi(conn: Conn<StatusLineOpen, Tuple4<Database.Subscription?, Database.User?, SubscriberState, Route.Api>>)
  -> IO<Conn<ResponseEnded, Data>> {

    let (subscription, _user, subscriberState, api) = lower(conn.data)
    let user = _user!

    switch api {
    case .account:
      return conn.map(const(user))
        |> writeStatus(.ok)
        >=> respond(encoder: JSONEncoder())

    case .auth:
      fatalError()
    }
}

public func respond<A>(json: Data) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return respond(data: json, contentType: .json)
}

import MediaType
public func respond<A>(data: Data, contentType: MediaType)
  -> Middleware<HeadersOpen, ResponseEnded, A, Data> {

    return map(const(data)) >>> pure
      >=> writeHeader(.contentType(contentType))
      >=> writeHeader(.contentLength(data.count))
      >=> closeHeaders
      >=> end
}

public func respond<A: Encodable>(encoder: JSONEncoder) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  return { conn in
    conn |> respond(json: try! JSONEncoder().encode(conn.data))
  }
}
