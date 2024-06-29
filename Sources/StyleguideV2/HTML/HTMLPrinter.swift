import OrderedCollections

public struct HTMLPrinter {
  public typealias Content = Never
  public var attributes: OrderedDictionary<String, String?> = [:]
  public var bytes: ContiguousArray<UInt8> = []
  public var styles: OrderedDictionary<MediaQuery?, OrderedDictionary<String, String>> = [:]

  public init() {}

  public var stylesheet: String {
    var sheet = ""
    for (mediaQuery, styles) in styles.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
      if let mediaQuery {
        sheet.append("@media \(mediaQuery.rawValue){")
      }
      defer {
        if mediaQuery != nil {
          sheet.append("}")
        }
      }
      for (className, style) in styles {
        sheet.append(".\(className){\(style)}")
      }
    }
    return sheet
  }
}
