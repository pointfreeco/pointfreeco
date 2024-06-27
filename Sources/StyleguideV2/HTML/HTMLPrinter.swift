import OrderedCollections

public struct HTMLPrinter {
  public typealias Content = Never
  var attributes: OrderedDictionary<String, String?> = [:]
  var bytes: ContiguousArray<UInt8> = []
  var styles: OrderedDictionary<String?, OrderedDictionary<String, String>> = [:]

  var stylesheet: String {
    var sheet = ""
    for (mediaQuery, styles) in styles.sorted(by: { $0.key == nil ? $1.key != nil : false }) {
      if let mediaQuery {
        sheet.append("@media \(mediaQuery){")
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
