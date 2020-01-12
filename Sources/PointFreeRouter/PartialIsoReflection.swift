import ApplicativeRouter
#if canImport(Darwin)
import Darwin
#elseif canImport(Glib)
import Glib.C
#endif
import Prelude

extension PartialIso {
  public static func `case`(_ embed: @escaping (A) -> B) -> PartialIso {
    return PartialIso(
      apply: { value in embed(value) },
      unapply: { extract(from: $0, via: embed) }
    )
  }
}

private func extract<Root, Value>(from root: Root, via embed: @escaping (Value) -> Root) -> Value? {
  func extractHelp(from root: Root) -> ([String], Value)? {
    var path: [String] = ["\(root)"]
    if let value = root as? Value {
      var otherRoot = embed(value)
      var root = root
      if memcmp(&root, &otherRoot, MemoryLayout<Root>.size) == 0 {
        return (path, value)
      }
    }
    var any: Any = root
    while case let (label?, anyChild)? = Mirror(reflecting: any).children.first {
      path.append(label)
      path.append(String(describing: type(of: anyChild)))
      if let child = anyChild as? Value {
        return (path, child)
      }
      any = anyChild
    }
    if Value.self == Void.self {
      return (path, ()) as? ([String], Value)
    }
    if Value.self == Unit.self {
      return (path, unit) as? ([String], Value)
    }
    return nil
  }
  guard
    let (rootPath, child) = extractHelp(from: root),
    let (otherPath, _) = extractHelp(from: embed(child)),
    rootPath == otherPath
    else { return nil }
  return child
}
