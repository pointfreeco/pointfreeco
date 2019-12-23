import Foundation
import HtmlUpgrade

public struct AtomAuthor {
  public var email: String
  public var name: String

  public init (email: String, name: String) {
    self.email = email
    self.name = name
  }
}

public struct AtomEntry {
  public var content: [Node]
  public var siteUrl: String
  public var title: String
  public var updated: Date

  public init (content: [Node], siteUrl: String, title: String, updated: Date) {
    self.title = title
    self.siteUrl = siteUrl
    self.updated = updated
    self.content = content
  }
}

public struct AtomFeed {
  public var atomUrl: String
  public var author: AtomAuthor
  public var entries: [AtomEntry]
  public var siteUrl: String
  public var title: String

  public init(atomUrl: String, author: AtomAuthor, entries: [AtomEntry], siteUrl: String, title: String) {
    self.atomUrl = atomUrl
    self.author = author
    self.entries = entries
    self.siteUrl = siteUrl
    self.title = title
  }
}

public func atomLayout(atomFeed: AtomFeed) -> [Node] {
  let updatedFields = atomFeed.entries
    .max { $0.updated < $1.updated }
    .map { updated($0.updated) }
    .map { [$0] } ?? []

  return [
    .raw("""
      <?xml version="1.0" encoding="utf-8"?>
      """
    ),
    feed(
      [xmlns("http://www.w3.org/2005/Atom")],
      (
        [
          title(atomFeed.title),
          .element(
            "link",
            [
              ("href", atomFeed.atomUrl),
              ("rel", "self")
            ],
            // NB: we need this so that the `<link>` is rendered with a close tag, which is required for XML.
            ""
          ),
          // NB: we need this so that the `<link>` is rendered with a close tag, which is required for XML.
          .element("link", [("href", atomFeed.siteUrl)], ""),
          id(atomFeed.siteUrl),
          author([
            name(atomFeed.author.name),
            email(atomFeed.author.email)
            ]),
          ]
          + updatedFields
          + atomFeed.entries.flatMap(atomEntry)
        )
        .compactMap { $0 }
    )
  ]
}

public func atomEntry(_ atomEntry: AtomEntry) -> [Node] {
  return [
    entry([
      title(atomEntry.title),
      // NB: we need this so that the `<link>` is rendered with a close tag, which is required for XML.
      element("link", [.init("href", atomEntry.siteUrl) as Attribute<Void>], [""]),
      updated(atomEntry.updated),
      id(atomEntry.siteUrl),
      content([type("html")], atomEntry.content)
      ])
  ]
}

extension Tag {
  public enum Author {}
  public enum Content {}
  public enum Feed {}
}

extension Attribute.Rel {
  public static var `self`: Self { .init(rawValue: "self") }
}

extension Node {
  public static func feed(attributes: [Attribute<Tag.Feed>], _ content: Node...) -> Node {
    return .element("feed", attributes: attributes, .fragment(content))
  }

  public static func title(_ title: String) -> Node {
    return .element("title", [], .text(title))
  }

  public static func link(attributes: [Attribute<Tag.Link>]) -> Node {
    return .element("link", attributes: attributes, .fragment([]))
  }

  public static func updated(_ date: Date) -> Node {
    return element("updated", [.text(atomDateFormatter.string(from: date))])
  }
}

extension Attribute where Element == Tag.Feed {
  public static func xmlns(_ xmlns: String) -> Self {
    return .init("xmlns", xmlns)
  }
}

public func id(_ id: String) -> Node {
  return element("id", [.text(id)])
}

public func author(_ content: [ChildOf<Tag.Author>]) -> Node {
  return element("author", content.map { $0.rawValue })
}

public func name(_ name: String) -> ChildOf<Tag.Author> {
  return .init(element("name", [.text(name)]))
}

public func email(_ email: String) -> ChildOf<Tag.Author> {
  return .init(element("email", [.text(email)]))
}

public func entry(_ content: [Node]) -> Node {
  return element("entry", content)
}

public func content(_ attribs: [Attribute<Tag.Content>], _ content: [Node]) -> Node {
  return element("content", attribs, [.raw("<![CDATA[" + render(content) + "]]>")])
}

public func type(_ type: String) -> Attribute<Tag.Content> {
  return .init("type", type)
}

private let atomDateFormatter = { () -> DateFormatter in
  let df = DateFormatter()
  df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
  df.locale = Locale(identifier: "en_US_POSIX")
  df.timeZone = TimeZone(secondsFromGMT: 0)
  return df
}()
