import Css
import Html
import HtmlCssSupport
import Foundation
import Styleguide
import Ccmark

let markdown = """
## Title

Some text **with** some __inline__ styles. And some inline code `f(x) = x`.
"""

func markdownToHtml(_ markdown: String) -> [Node] {

  func inlinecode(_ markdown: String) -> [Node] {
    return markdown
      .components(separatedBy: "`")
      .enumerated()
      .map { idx, fragment in
        idx % 2 == 0
          ? text(fragment)
          : span([`class`([Class.pf.inlineCode])], [text(fragment)])
    }
  }

  func bolds(_ markdown: String) -> [Node] {
    return markdown
      .components(separatedBy: "**")
      .enumerated()
      .map { idx, fragment in
        idx % 2 == 0
          ? text(fragment)
          : em([], [text(fragment)])
    }
  }

//  let withBolds = inlineCode(markdown)
//    .map {


  return withBolds
}

print(render(markdownToHtml(markdown), config: compact))


1
