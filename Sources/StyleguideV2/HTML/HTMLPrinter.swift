import OrderedCollections

public struct HTMLPrinter {
  public typealias Content = Never
  var attributes: OrderedDictionary<String, String?> = [:]
  var bytes: ContiguousArray<UInt8> = []
  var styles: OrderedDictionary<String?, OrderedDictionary<String, String>> = [:]

  var stylesheet: String {
    var sheet = ""
    for (mediaQuery, styles) in styles {
      for (className, style) in styles {
        if let mediaQuery {
          sheet.append("""
            @media \(mediaQuery){.\(className){\(style)}}
            """)
        } else {
          sheet.append(".\(className){\(style)}")
        }
      }
    }
    return sheet
  }
}
