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
    printer.bytes.append(UInt8(ascii: "<"))
    printer.bytes.append(contentsOf: html.tag.utf8)
    for (name, value) in printer.attributes {
      printer.bytes.append(UInt8(ascii: " "))
      printer.bytes.append(contentsOf: name.utf8)
      if !value.isEmpty {
        printer.bytes.append(contentsOf: "=\"".utf8)
        for byte in value.utf8 {
          guard byte != UInt8(ascii: "\"") else {
            printer.bytes.append(contentsOf: "&quot;".utf8)
            continue
          }
          printer.bytes.append(byte)
        }
        printer.bytes.append(UInt8(ascii: "\""))
      }
    }
    printer.bytes.append(UInt8(ascii: ">"))
    if let content = html.content {
      let oldAttributes = printer.attributes
      defer { printer.attributes = oldAttributes }

      printer.attributes.removeAll()
      Content._render(content, into: &printer)
    }
    if !HTMLVoidTag.allTags.contains(html.tag) {
      printer.bytes.append(contentsOf: "</".utf8)
      printer.bytes.append(contentsOf: html.tag.utf8)
      printer.bytes.append(UInt8(ascii: ">"))
    }
  }
}
