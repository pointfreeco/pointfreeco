import Html
import Optics
import Prelude

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
      |> map(^\.node)
  }
}

private func inserted<A>(meta: Metadata<A>, intoHeadOf nodes: [Node]) -> [Node] {

  return nodes.map { node -> Node in

    switch node {
    case .comment:
      return node

    case let .document(nodes):
      return .document(inserted(meta: meta, intoHeadOf: nodes))

    case let .element(element) where element.name == "head":
      return
        .element(
          element
            |> \.content %~ map { $0 + meta.metaNodes }
        )

    case let .element(element):
      return .element(
        element
          |> \.content %~ map { inserted(meta: meta, intoHeadOf: $0) }
      )

    case .text:
      return node
    }
  }
}

public func metaLayout<A>(_ view: View<A>) -> View<Metadata<A>> {
  return .init { meta in
    inserted(meta: meta, intoHeadOf: view.view(meta.rest))
  }
}
