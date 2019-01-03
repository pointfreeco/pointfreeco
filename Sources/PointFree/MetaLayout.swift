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

  var metaNodes: Node {
    let description: ChildOf<Tag.Head> = self.description
      .map {
        [
          meta(name: "description", content: $0),
          meta(property: "og:description", content: $0),
          meta(name: "twitter:description", content: $0),
        ]
      }
      ?? []

    let image: ChildOf<Tag.Head> = self.image
      .map {
        [
          meta(name: "twitter:image", content: $0),
          meta(property: "og:image", content: $0),
        ]
      }
      ?? []

    let title: ChildOf<Tag.Head> = self.title
      .map {
        [
          meta(name: "title", content: $0),
          meta(property: "og:title", content: $0),
          meta(name: "twitter:title", content: $0),
        ]
      }
      ?? []

    let type: ChildOf<Tag.Head> = self.type
      .map { meta(property: "og:type", content: $0.rawValue) }
      ?? []
    let twitterCard: ChildOf<Tag.Head> = self.twitterCard
      .map { meta(name: "twitter:card", content: $0.rawValue) }
      ?? []
    let twitterSite: ChildOf<Tag.Head> = self.twitterSite
      .map { meta(name: "twitter:site", content: $0) }
      ?? []
    let url: ChildOf<Tag.Head> = self.url
      .map {
        [
          meta(property: "og:url", content: $0),
          meta(name: "twitter:url", content: $0),
        ]
      }
      ?? []

    return (
      ...[
        description,
        image,
        title,
        type,
        twitterCard,
        twitterSite,
        url,
      ]
      ).rawValue
  }
}

private func inserted<A>(meta: Metadata<A>, intoHeadOf node: Node) -> Node {

  switch node {
  case let .element("head", attribs, children):
    return .element("head", attribs, [children, meta.metaNodes])

  case let .element(tag, attribs, children):
    return .element(tag, attribs, inserted(meta: meta, intoHeadOf: children))

  case let .fragment(children):
    return ...children.map { inserted(meta: meta, intoHeadOf: $0) }

  case .comment, .doctype, .raw, .text:
    return node
  }
}

public func metaLayout<A>(_ view: View<A>) -> View<Metadata<A>> {
  return .init { meta in
    inserted(meta: meta, intoHeadOf: view.view(meta.rest))
  }
}
