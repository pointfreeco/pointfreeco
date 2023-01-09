import Cryptor
import Css
import Dependencies
import Dispatch
import Either
import Foundation
import Html
import HtmlPlainTextPrint
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreeRouter
import Prelude
import Styleguide
import Tagged
import Tuple
import UrlFormEncoding

extension IO {
  public static func pure(_ a: A) -> IO {
    Prelude.pure(a)
  }
}

public typealias M<A> = Middleware<StatusLineOpen, ResponseEnded, A, Data>
public typealias MT<A, B> = (@escaping M<B>) -> M<A>

// todo: swift-prelude?
// todo: rename to `tupleArray`?
public func array<A>(_ tuple: (A, A, A, A, A, A, A, A, A)) -> [A] {
  return [tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7, tuple.8]
}

// TODO: Move to HttpPipeline

/// Lifts middleware that operates on non-optional values to one that operates on optionals, but renders
/// a 404 not found view in place of `nil` values.
///
/// - Parameter notFoundView: A view to render in case of encountering a `nil` value.
/// - Returns: New middleware that operates on optional values.
public func requireSome<A>(
  notFoundView: Node
)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A?, Data>
{

  return { middleware in
    return { conn in
      return conn.data
        .map { conn.map(const($0)) }
        .map(middleware)
        ?? (conn.map(const(unit))
          |> writeStatus(.notFound)
          >=> respond({ _ in notFoundView }))
    }
  }
}

// PreludeFoundation

public func responseTimeout(_ interval: TimeInterval)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>
{

  return { middleware in
    return { conn in
      let timeout =
        middleware(conn).parallel
        <|> (conn
        |> writeStatus(.internalServerError)
        >=> respond(html: "<h1>Response Time-out</h1>"))
        .delay(interval)
        .parallel

      return timeout.sequential
    }
  }
}

public func respond<A>(
  _ view: @escaping (A) -> Node
) -> Middleware<HeadersOpen, ResponseEnded, A, Data> {
  @Dependency(\.renderHtml) var renderHtml

  return { conn in
    conn
      |> respond(
        body: renderHtml(view(conn.data)),
        contentType: .html
      )
  }
}
