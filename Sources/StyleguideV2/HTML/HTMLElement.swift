import OrderedCollections

public struct HTMLElement<Content: HTML>: HTML {
  public var body: Never {
    fatalError()
  }
  let tag: String
  @HTMLBuilder let content: Content?
  public init(tag: String, @HTMLBuilder content: () -> Content? = { Never?.none }) {
    self.tag = tag
    self.content = content()
  }
  public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    if html.isBlock {
      printer.bytes.append(contentsOf: printer.configuration.newline.utf8)
      printer.bytes.append(contentsOf: printer.currentIndentation.utf8)
    }
    printer.bytes.append(UInt8(ascii: "<"))
    printer.bytes.append(contentsOf: html.tag.utf8)
    for (name, value) in printer.attributes {
      printer.bytes.append(UInt8(ascii: " "))
      printer.bytes.append(contentsOf: name.utf8)
      if !value.isEmpty {
        printer.bytes.append(contentsOf: "=\"".utf8)
        for byte in value.utf8 {
          switch byte {
          case UInt8(ascii: "\""):
            printer.bytes.append(contentsOf: "&quot;".utf8)
          case UInt8(ascii: "'"):
            printer.bytes.append(contentsOf: "&#39;".utf8)
          default:
            printer.bytes.append(byte)
          }
        }
        printer.bytes.append(UInt8(ascii: "\""))
      }
    }
    printer.bytes.append(UInt8(ascii: ">"))
    if let content = html.content {
      let oldAttributes = printer.attributes
      let oldIndentation = printer.currentIndentation
      defer {
        printer.attributes = oldAttributes
        printer.currentIndentation = oldIndentation
      }
      printer.attributes.removeAll()
      if html.isBlock {
        printer.currentIndentation += printer.configuration.indentation
      }
      Content._render(content, into: &printer)
    }
    if !HTMLVoidTag.allTags.contains(html.tag) {
      if html.isBlock {
        printer.bytes.append(contentsOf: printer.configuration.newline.utf8)
        printer.bytes.append(contentsOf: printer.currentIndentation.utf8)
      }
      printer.bytes.append(contentsOf: "</".utf8)
      printer.bytes.append(contentsOf: html.tag.utf8)
      printer.bytes.append(UInt8(ascii: ">"))
    }
  }
  private var isBlock: Bool {
    !inlineTags.contains(tag)
  }
}

private let inlineTags: Set<String> = [
  "a",
  "abbr",
  "acronym",
  "b",
  "bdo",
  "big",
  "br",
  "button",
  "cite",
  "code",
  "dfn",
  "em",
  "i",
  "img",
  "input",
  "kbd",
  "label",
  "map",
  "object",
  "output",
  "q",
  "samp",
  "script",
  "select",
  "small",
  "span",
  "strong",
  "sub",
  "sup",
  "textarea",
  "time",
  "tt",
  "var",
]
