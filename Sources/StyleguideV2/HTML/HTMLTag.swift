public struct HTMLTag: HTML, ExpressibleByStringLiteral {
  let rawValue: StaticString

  init(_ rawValue: StaticString) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: StaticString) {
    self.init(value)
  }

  public var body: some HTML {
    tag(self.rawValue)
  }

  public func callAsFunction(@HTMLBuilder _ content: () -> some HTML) -> some HTML {
    tag(self.rawValue, content)
  }

  // TODO: Consider how this should work
  // public var a: HTMLTag { ... }
}

public struct HTMLTextTag: HTML, ExpressibleByStringLiteral {
  let rawValue: StaticString

  init(_ rawValue: StaticString) {
    self.rawValue = rawValue
  }

  public init(stringLiteral value: StaticString) {
    self.init(value)
  }

  public var body: some HTML {
    tag(self.rawValue)
  }

  public func callAsFunction(_ content: String) -> some HTML {
    tag(self.rawValue) { content }
  }

  public func callAsFunction(_ content: () -> String) -> some HTML {
    tag(self.rawValue) { content() }
  }
}

// extension HTML {
public func tag(
  _ tag: StaticString, @HTMLBuilder _ content: () -> (some HTML)? = { Never?.none }
) -> some HTML {
  HTMLElement(tag: tag, content: content)
}

public var a: HTMLTag { #function }
public var abbr: HTMLTag { #function }
public var acronym: HTMLTag { #function }
public var address: HTMLTag { #function }
public var applet: HTMLTag { #function }
public var area: HTMLTag { #function }
public var article: HTMLTag { #function }
public var aside: HTMLTag { #function }
public var audio: HTMLTag { #function }
public var b: HTMLTag { #function }
public var base: HTMLTag { #function }
public var basefront: HTMLTag { #function }
public var bdi: HTMLTag { #function }
public var bdo: HTMLTag { #function }
public var big: HTMLTag { #function }
public var blockquote: HTMLTag { #function }
// public var body: HTMLTag { #function }
public var br: HTMLTag { #function }
public var button: HTMLTag { #function }
public var canvas: HTMLTag { #function }
public var caption: HTMLTag { #function }
public var center: HTMLTag { #function }
public var cite: HTMLTag { #function }
public var code: HTMLTag { #function }
public var col: HTMLTag { #function }
public var colgroup: HTMLTag { #function }
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
public var embed: HTMLTag { #function }
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
// public var head: HTMLTag { #function }
public var header: HTMLTag { #function }
public var hr: HTMLTag { #function }
public var html: HTMLTag { #function }
public var i: HTMLTag { #function }
public var iframe: HTMLTag { #function }
public var img: HTMLTag { #function }
public var input: HTMLTag { #function }
public var ins: HTMLTag { #function }
public var kbd: HTMLTag { #function }
public var label: HTMLTag { #function }
public var legend: HTMLTag { #function }
public var li: HTMLTag { #function }
public var link: HTMLTag { #function }
public var main: HTMLTag { #function }
public var map: HTMLTag { #function }
public var mark: HTMLTag { #function }
public var meta: HTMLTextTag { #function }
public var meter: HTMLTag { #function }
public var nav: HTMLTag { #function }
public var noframes: HTMLTag { #function }
public var noscript: HTMLTag { #function }
public var object: HTMLTag { #function }
public var ol: HTMLTag { #function }
public var optgroup: HTMLTag { #function }
public var option: HTMLTextTag { #function }
public var p: HTMLTag { #function }
public var param: HTMLTag { #function }
public var picture: HTMLTag { #function }
public var pre: HTMLTag { #function }
public var progress: HTMLTag { #function }
public var q: HTMLTag { #function }
public var rp: HTMLTag { #function }
public var rt: HTMLTag { #function }
public var s: HTMLTag { #function }
public var samp: HTMLTag { #function }
public var script: HTMLTextTag { #function }
public var section: HTMLTag { #function }
public var select: HTMLTag { #function }
public var small: HTMLTag { #function }
public var source: HTMLTag { #function }
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
public var track: HTMLTag { #function }
public var tt: HTMLTag { #function }
public var u: HTMLTag { #function }
public var ul: HTMLTag { #function }
public var `var`: HTMLTag { #function }
public var video: HTMLTag { #function }
public var wbr: HTMLTag { #function }
// }
