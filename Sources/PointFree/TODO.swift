import ApplicativeRouter
import Cryptor
import Css
import Dispatch
import Either
import Foundation
import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import UrlFormEncoding
import View

extension Tagged where Tag == EncryptedTag, RawValue == String {
  public init?(_ text: String, with secret: EnvVars.Secret) {
    guard
      let string = encrypted(text: text, secret: secret.rawValue)
      else { return nil }
    self.init(rawValue: string)
  }

  public func decrypt(with secret: EnvVars.Secret) -> String? {
    return decrypted(text: self.rawValue, secret: secret.rawValue)
  }
}

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
  notFoundView: View<Prelude.Unit>
  )
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, A, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, A?, Data> {

    return { middleware in
      return { conn in
        return conn.data
          .map { conn.map(const($0)) }
          .map(middleware)
          ?? (
            conn.map(const(unit))
              |> writeStatus(.notFound)
              >=> respond(notFoundView)
        )
      }
    }
}

/// Combines two partial iso's into one by concatenating their results into a single string.
public func payload<A, B>(
  _ iso1: PartialIso<String, A>,
  _ iso2: PartialIso<String, B>,
  separator: String = "--POINT-FREE-BOUNDARY--"
  )
  -> PartialIso<String, (A, B)> {

    return PartialIso<String, (A, B)>(
      apply: { payload in
        let parts = payload.components(separatedBy: separator)
        let first = parts.first.flatMap(iso1.apply)
        let second = parts.last.flatMap(iso2.apply)
        return tuple <¢> first <*> second
    },
      unapply: { first, second in
        guard
          let first = iso1.unapply(first),
          let second = iso2.unapply(second)
          else { return nil }
        return "\(first)\(separator)\(second)"
    })
}


// PreludeFoundation

public func responseTimeout(_ interval: TimeInterval)
  -> (@escaping Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, Prelude.Unit, Data> {

    return { middleware in
      return { conn in
        let timeout = middleware(conn).parallel <|> (
          conn
            |> writeStatus(.internalServerError)
            >=> respond(html: "<h1>Response Time-out</h1>")
          )
          .delay(interval)
          .parallel

        return timeout.sequential
      }
    }
}

func text(_ string: String) -> Node {
  return .text(string)
}

func playsinline(_ value: Bool) -> Attribute<Tag.Video> {
  return .init("playslinline", value ? "" : nil)
}
