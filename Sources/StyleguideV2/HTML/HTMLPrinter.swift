import Dependencies
import OrderedCollections

public struct HTMLPrinter {
  public typealias Content = Never
  public var attributes: OrderedDictionary<String, String> = [:]
  public var bytes: ContiguousArray<UInt8> = []
  public var styles: OrderedDictionary<MediaQuery?, OrderedDictionary<String, String>> = [:]

  var classes: OrderedSet<AnyHashable> = []
  let configuration: Configuration
  var currentIndentation = ""

  public init(_ configuration: Configuration = .default) {
    self.configuration = configuration
  }

  public var stylesheet: String {
    var sheet = configuration.newline
    for (mediaQuery, styles) in styles.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
      var currentIndentation = ""
      if let mediaQuery {
        sheet.append("@media \(mediaQuery.rawValue){")
        sheet.append(configuration.newline)
        currentIndentation.append(configuration.indentation)
      }
      defer {
        if mediaQuery != nil {
          sheet.append("}")
          sheet.append(configuration.newline)
        }
      }
      for (className, style) in styles {
        sheet.append(currentIndentation)
        sheet.append("\(className){\(style)}")
        sheet.append(configuration.newline)
      }
    }
    return sheet
  }

  public struct Configuration {
    let indentation: String
    let newline: String

    public static let `default` = Self(indentation: "", newline: "")
    public static let pretty = Self(indentation: "  ", newline: "\n")
  }
}

extension HTML {
  public func render() -> ContiguousArray<UInt8> {
    @Dependency(\.htmlPrinter) var htmlPrinter
    var printer = htmlPrinter
    Self._render(self, into: &printer)
    return printer.bytes
  }
}

extension HTMLDocument {
  public func render() -> ContiguousArray<UInt8> {
    @Dependency(\.htmlPrinter) var htmlPrinter
    var printer = htmlPrinter
    Self._render(self, into: &printer)
    return printer.bytes
  }
}

extension DependencyValues {
  public var htmlPrinter: HTMLPrinter {
    get { self[HTMLPrinterKey.self] }
    set { self[HTMLPrinterKey.self] = newValue }
  }
}

private enum HTMLPrinterKey: DependencyKey {
  static var liveValue: HTMLPrinter { HTMLPrinter() }
  static var testValue: HTMLPrinter { HTMLPrinter(.pretty) }
}
