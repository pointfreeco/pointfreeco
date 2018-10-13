import Html
import Optics
import Prelude
import View

// TODO: extract to swift-web

// https://developers.facebook.com/docs/reference/opengraph#object-type
public enum OpenGraphType: String {
  case website
}

public enum TwitterCard: String {
  case app
  case player
  case summary
  case summaryLargeImage = "summary_large_image"
}

public struct Metadata<A> {
  public let description: String?
  public let image: String?
  public let rest: A
  public let title: String?
  public let twitterCard: TwitterCard?
  /// @username of website. Either twitter:site or twitter:site:id is required.
  public let twitterSite: String?
  public let type: OpenGraphType?
  public let url: String?

  public static func create(
    description: String? = nil,
    image: String? = nil,
    title: String? = nil,
    twitterCard: TwitterCard? = nil,
    twitterSite: String? = nil,
    type: OpenGraphType? = nil,
    url: String? = nil
    )
    -> (A) -> Metadata<A> {
      return { rest in
        .init(
          description: description,
          image: image,
          rest: rest,
          title: title,
          twitterCard: twitterCard,
          twitterSite: twitterSite,
          type: type,
          url: url
        )
      }
  }

  var metaNodes: [Node] {
    return [

      self.description.map { meta(name: "description", content: $0) },
      self.description.map { meta(property: "og:description", content: $0) },
      self.description.map { meta(name: "twitter:description", content: $0) },

      self.image.map { meta(name: "twitter:image", content: $0) },
      self.image.map { meta(property: "og:image", content: $0) },

      self.title.map { meta(name: "title", content: $0) },
      self.title.map { meta(property: "og:title", content: $0) },
      self.title.map { meta(name: "twitter:title", content: $0) },

      self.type.map { meta(property: "og:type", content: $0.rawValue) },

      self.twitterCard.map { meta(name: "twitter:card", content: $0.rawValue) },
      self.twitterSite.map { meta(name: "twitter:site", content: $0) },

      self.url.map { meta(property: "og:url", content: $0) },
      self.url.map { meta(name: "twitter:url", content: $0) },

      ]
      |> catOptionals
      |> map(^\.rawValue)
  }
}

private func inserted<A>(meta: Metadata<A>, intoHeadOf nodes: [Node]) -> [Node] {

  return nodes.map { node -> Node in

    switch node {
    case let .element(tag, attribs, children):
      return .element(
        tag,
        attribs,
        tag == "head"
          ? children + meta.metaNodes
          : inserted(meta: meta, intoHeadOf: children)
      )

    case .comment, .doctype, .raw, .text:
      return node
    }
  }
}

public func metaLayout<A>(_ view: View<A>) -> View<Metadata<A>> {
  return .init { meta in
    inserted(meta: meta, intoHeadOf: view.view(meta.rest))
  }
}
