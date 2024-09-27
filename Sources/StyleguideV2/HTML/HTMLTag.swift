public struct HTMLTag: ExpressibleByStringLiteral {
  let rawValue: String

  init(_ rawValue: String) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: String) {
    self.init(value)
  }

  public func callAsFunction() -> HTMLElement<HTMLEmpty> {
    tag(self.rawValue)
  }

  public func callAsFunction<T: HTML>(@HTMLBuilder _ content: () -> T) -> HTMLElement<T> {
    tag(self.rawValue, content)
  }
}

public struct HTMLTextTag: ExpressibleByStringLiteral {
  let rawValue: String

  init(_ rawValue: String) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: String) {
    self.init(value)
  }

  public func callAsFunction(_ content: String = "") -> HTMLElement<HTMLText> {
    tag(self.rawValue) { HTMLText(content) }
  }

  public func callAsFunction(_ content: () -> String) -> HTMLElement<HTMLText> {
    tag(self.rawValue) { HTMLText(content()) }
  }
}

public struct HTMLVoidTag: ExpressibleByStringLiteral {
  public static let allTags: Set<String> = [
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr",
  ]

  let rawValue: String

  init(_ rawValue: String) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: String) {
    self.init(value)
  }

  public func callAsFunction() -> HTMLElement<HTMLEmpty> {
    tag(self.rawValue) { HTMLEmpty() }
  }
}

public func tag<T: HTML>(
  _ tag: String,
  @HTMLBuilder _ content: () -> T = { HTMLEmpty() }
) -> HTMLElement<T> {
  HTMLElement(tag: tag, content: content)
}

public func blockTag<T>(
  _ customTag: String,
  @HTMLBuilder _ content: () -> T = { HTMLEmpty() }
) -> HTMLElement<T> {
  if HTMLLocals.isCustomTagSupported {
    return tag(customTag, content)
  } else {
    return tag("div", content)
  }
}

public var a: HTMLTag { #function }
public var abbr: HTMLTag { #function }
public var acronym: HTMLTag { #function }
public var address: HTMLTag { #function }
public var applet: HTMLTag { #function }
public var area: HTMLVoidTag { #function }
public var article: HTMLTag { #function }
public var aside: HTMLTag { #function }
public var audio: HTMLTag { #function }
public var b: HTMLTag { #function }
public var base: HTMLVoidTag { #function }
public var basefront: HTMLTag { #function }
public var bdi: HTMLTag { #function }
public var bdo: HTMLTag { #function }
public var big: HTMLTag { #function }
public var blockquote: HTMLTag { #function }
@available(*, unavailable, message: "Use 'HTMLDocument.head', instead.")
public var body: HTMLTag { #function }
public var br: HTMLVoidTag { #function }
public var button: HTMLTag { #function }
public var canvas: HTMLTag { #function }
public var caption: HTMLTag { #function }
public var center: HTMLTag { #function }
public var cite: HTMLTag { #function }
public var code: HTMLTag { #function }
public var col: HTMLVoidTag { #function }
public var colgroup: HTMLTag { #function }
public var command: HTMLVoidTag { #function }
public var data: HTMLTag { #function }
public var datalist: HTMLTag { #function }
public var dd: HTMLTag { #function }
public var del: HTMLTag { #function }
public var details: HTMLTag { #function }
public var dfn: HTMLTag { #function }
public var dialog: HTMLTag { #function }
public var dir: HTMLTag { #function }
public var div: HTMLTag { #function }
public var dl: HTMLTag { #function }
public var dt: HTMLTag { #function }
public var em: HTMLTag { #function }
public var embed: HTMLVoidTag { #function }
public var fieldset: HTMLTag { #function }
public var figcaption: HTMLTag { #function }
public var figure: HTMLTag { #function }
public var font: HTMLTag { #function }
public var footer: HTMLTag { #function }
public var form: HTMLTag { #function }
public var frame: HTMLTag { #function }
public var frameset: HTMLTag { #function }
public var h1: HTMLTag { #function }
public var h2: HTMLTag { #function }
public var h3: HTMLTag { #function }
public var h4: HTMLTag { #function }
public var h5: HTMLTag { #function }
public var h6: HTMLTag { #function }
@available(*, unavailable, message: "Use 'HTMLDocument.head', instead.")
public var head: HTMLTag { #function }
public var header: HTMLTag { #function }
public var hr: HTMLVoidTag { #function }
public var html: HTMLTag { #function }
public var i: HTMLTag { #function }
public var iframe: HTMLTag { #function }
public var img: HTMLVoidTag { #function }
public var input: HTMLVoidTag { #function }
public var ins: HTMLTag { #function }
public var kbd: HTMLTag { #function }
public var keygen: HTMLVoidTag { #function }
public var label: HTMLTag { #function }
public var legend: HTMLTag { #function }
public var li: HTMLTag { #function }
public var link: HTMLVoidTag { #function }
public var main: HTMLTag { #function }
public var map: HTMLTag { #function }
public var mark: HTMLTag { #function }
public var meta: HTMLVoidTag { #function }
public var meter: HTMLTag { #function }
public var nav: HTMLTag { #function }
public var noframes: HTMLTag { #function }
public var noscript: HTMLTag { #function }
public var object: HTMLTag { #function }
public var ol: HTMLTag { #function }
public var optgroup: HTMLTag { #function }
public var option: HTMLTextTag { #function }
public var p: HTMLTag { #function }
public var param: HTMLVoidTag { #function }
public var picture: HTMLTag { #function }
public var pre: HTMLTag { #function }
public var progress: HTMLTag { #function }
public var q: HTMLTag { #function }
public var rp: HTMLTag { #function }
public var rt: HTMLTag { #function }
public var s: HTMLTag { #function }
public var samp: HTMLTag { #function }
public func script(_ text: () -> String = { "" }) -> HTMLElement<HTMLRaw> {
  let text = text()
  var escaped = ""
  escaped.unicodeScalars.reserveCapacity(text.unicodeScalars.count)
  for index in text.unicodeScalars.indices {
    let scalar = text.unicodeScalars[index]
    if scalar == "<",
      text.unicodeScalars[index...].starts(with: "<!--".unicodeScalars)
        || text.unicodeScalars[index...].starts(with: "<script".unicodeScalars)
        || text.unicodeScalars[index...].starts(with: "</script".unicodeScalars)
    {
      escaped.unicodeScalars.append(contentsOf: #"\x3C"#.unicodeScalars)
    } else {
      escaped.unicodeScalars.append(scalar)
    }
  }
  return tag("script") {
    HTMLRaw(escaped)
  }
}
public var section: HTMLTag { #function }
public var select: HTMLTag { #function }
public var small: HTMLTag { #function }
public var source: HTMLVoidTag { #function }
public var span: HTMLTag { #function }
public var strike: HTMLTag { #function }
public var strong: HTMLTag { #function }
public var style: HTMLTextTag { #function }
public var sub: HTMLTag { #function }
public var summary: HTMLTag { #function }
public var sup: HTMLTag { #function }
public var svg: HTMLTag { #function }
public var table: HTMLTag { #function }
public var tbody: HTMLTag { #function }
public var td: HTMLTag { #function }
public var template: HTMLTag { #function }
public var textarea: HTMLTextTag { #function }
public var tfoot: HTMLTag { #function }
public var th: HTMLTag { #function }
public var thead: HTMLTag { #function }
public var time: HTMLTag { #function }
public var title: HTMLTextTag { #function }
public var tr: HTMLTag { #function }
public var track: HTMLVoidTag { #function }
public var tt: HTMLTag { #function }
public var u: HTMLTag { #function }
public var ul: HTMLTag { #function }
public var `var`: HTMLTag { #function }
public var video: HTMLTag { #function }
public var wbr: HTMLVoidTag { #function }
