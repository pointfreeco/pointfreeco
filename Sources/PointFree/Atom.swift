import Foundation
import Html
import Optics
import Prelude
import View

public struct AtomAuthor {
  public var email: String
  public var name: String
}

public struct AtomEntry {
  public var title: String
  public var siteUrl: String
  public var updated: Date
  public var content: [Node]
}

public struct AtomFeed {
  public var author: AtomAuthor
  public var entries: [AtomEntry]
  public var atomUrl: String
  public var siteUrl: String
  public var title: String
}

public let atomLayout = View<AtomFeed> { atomFeed -> [Node] in
  [
    .raw("""
      <?xml version="1.0" encoding="utf-8"?>
      """
    ),
    feed(
      [xmlns("http://www.w3.org/2005/Atom")],
      [
        title(atomFeed.title),
        link([href(atomFeed.atomUrl), rel(.self)]),
        link([href(atomFeed.siteUrl)]),
        atomFeed.entries.map(^\.updated).max().map(updated),
        id(atomFeed.siteUrl),
        author([
          name(atomFeed.author.name),
          email(atomFeed.author.email)
          ]),
        ]
        <> atomFeed.entries.flatMap(atomEntry.view)
        |> catOptionals
    )
  ]
}

public let atomEntry = View<AtomEntry> { atomEntry in
  return entry([
    title(atomEntry.title),
    link([href(atomEntry.siteUrl)]),
    updated(atomEntry.updated),
    id(atomEntry.siteUrl),
    content([type("html")], atomEntry.content)
    ])
}

extension Tag {
  public enum Author {}
  public enum Content {}
  public enum Feed {}
}

extension Rel {
  public static let `self` = value("self")
}

public func feed(_ attribs: [Attribute<Tag.Feed>], _ content: [Node]) -> Node {
  return .el("feed", attribs, content)
}

public func xmlns(_ xmlns: String) -> Attribute<Tag.Feed> {
  return .init("xmlns", xmlns)
}

public func title(_ title: String) -> Node {
  return .el("title", [.text(title)])
}

public func link(_ attribs: [Attribute<Tag.Link>]) -> Node {
  return .el("link", attribs, [])
}

public func updated(_ date: Date) -> Node {
  return .el("updated", [.text(atomDateFormatter.string(from: date))])
}

public func id(_ id: String) -> Node {
  return .el("id", [.text(id)])
}

public func author(_ content: [ChildOf<Tag.Author>]) -> Node {
  return .el("author", content.map(^\.node))
}

public func name(_ name: String) -> ChildOf<Tag.Author> {
  return .init(.el("name", [.text(name)]))
}

public func email(_ email: String) -> ChildOf<Tag.Author> {
  return .init(.el("email", [.text(email)]))
}

public func entry(_ content: [Node]) -> Node {
  return .el("entry", content)
}

public func content(_ attribs: [Attribute<Tag.Content>], _ content: [Node]) -> Node {
  return .el("content", attribs, [.raw("<![CDATA[" + render(content).string + "]]>")])
}

public func type(_ type: String) -> Attribute<Tag.Content> {
  return .init("type", type)
}

private let atomDateFormatter = DateFormatter()
  |> \.dateFormat .~ "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
  |> \.locale .~ Locale(identifier: "en_US_POSIX")
  |> \.timeZone .~ TimeZone(secondsFromGMT: 0)
