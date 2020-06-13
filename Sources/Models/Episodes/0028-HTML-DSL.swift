import Foundation

extension Episode {
  static let ep28_anHtmlDsl = Episode(
    blurb: """
      This week we apply domain-specific languages to a very real-world problem: representing and rendering HTML. We code up a simple but powerful solution that forms the foundation of what we use to build the Point-Free website.
      """,
    codeSampleDirectory: "0028-html-dsl",
    exercises: _exercises,
    id: 28,
    image: "https://i.vimeocdn.com/video/801301977.jpg",
    length: 23 * 60 + 6,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_535_954_223),
    references: [.openSourcingSwiftHtml],
    sequence: 28,
    title: "An HTML DSL",
    trailerVideo: .init(
      bytesLength: 41_859_651,
      downloadUrl:
        "https://player.vimeo.com/external/348635621.hd.mp4?s=8a0859f2ced9584d8f70946e21b8bd2dc1c2fe06&profile_id=175&download=1",
      streamingSource: "https://player.vimeo.com/video/348635621"
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  Episode.Exercise(
    problem: """
      Our `render` function currently prints an extra space when attributes aren't present: `"<header ></header>"`. Fix the `render` function so that `render(header([])) == "<header></header>"`.
      """),
  Episode.Exercise(
    problem: """
      HTML specifies a number of "[void elements](https://www.w3.org/TR/html5/syntax.html#void-elements)" (elements that have no closing tag). This includes the `img` element in our example. Update the `render` function to omit the closing tag on void elements.
      """),
  Episode.Exercise(
    problem: """
      Our `render` function is currently unsafe: text node content isn't escaped, which means it could be susceptible to cross-site scripting attacks. Ensure that text nodes are properly escaped during rendering.
      """),
  Episode.Exercise(
    problem: """
      Ensure that attribute nodes are properly escaped during rendering.
      """),
  Episode.Exercise(
    problem: """
      Write a function `redacted`, which transforms a `Node` and its children, replacing all non-whitespace characters with a redacted character: `█`.
      """),
  Episode.Exercise(
    problem: """
      Write a function `removingStyles`, which removes all `style` nodes and attributes.
      """),
  Episode.Exercise(
    problem: """
      Write a function `removingScripts`, which removes all `script` nodes and attributes with the `on` prefix (like `onclick`).
      """),
  Episode.Exercise(
    problem: """
      Write a function `plainText`, which transforms HTML into human-readable text, which might be useful for rendering plain-text emails from HTML content.
      """),
  Episode.Exercise(
    problem: """
      One of the most popular way of rendering HTML is to use a templating language (Swift, for example, has [Stencil](https://github.com/stencilproject/Stencil)). What are some of the pros and cons of using a templating language over a DSL.
      """),
]
