import ApplicativeRouter
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif
import Prelude

extension PartialIso {
  @inlinable
  public static func `case`(_ embed: @escaping (A) -> B) -> PartialIso {
    return PartialIso(
      apply: embed,
      unapply: { extract(from: $0, via: embed) }
    )
  }
}

extension PartialIso where A == Void {
  @inlinable
  public static func `case`(_ value: B) -> PartialIso {
    let description = "\(value)"
    return PartialIso(
      apply: { _ in value },
      unapply: { "\($0)" == description ? () : nil }
    )
  }
}

extension PartialIso where A == B {
  @inlinable
  public static func `case`(_ embed: @escaping (A) -> B) -> PartialIso {
    return PartialIso(
      apply: embed,
      unapply: embed
    )
  }
}

@inlinable
func extract<Root, Value>(from root: Root, via embed: @escaping (Value) -> Root) -> Value? {
  func extractHelp(from root: Root) -> ([String], Value)? {
    var path: [String] = []
    var any: Any = root
    while case let (label?, anyChild)? = Mirror(reflecting: any).children.first {
      path.append(label)
      path.append(String(describing: type(of: anyChild)))
      if let child = anyChild as? Value {
        return (path, child)
      }
      any = anyChild
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
