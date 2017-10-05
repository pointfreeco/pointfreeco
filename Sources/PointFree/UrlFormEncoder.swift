import Foundation
import Prelude

// todo: move to swift-web

/// Encodes an encodable into `x-www-form-urlencoded` format. It first converts the value into a JSON
/// dictionary, and then it encodes that into the format.
///
/// - Parameter value: The encodable value to encode.
public func urlFormEncode<A: Encodable>(value: A) -> String {

  return (try? JSONEncoder().encode(value))
    .flatMap { try? JSONSerialization.jsonObject(with: $0) }
    .flatMap { $0 as? [String: Any] }
    .map(urlFormEncode(value:))
    ?? ""
}

/// Encodes an array into `x-www-form-urlencoded` format.
///
/// - Parameters:
///   - value: The array of values to encode.
///   - rootKey: A root key to hold the array.
public func urlFormEncode(values: [Any], rootKey: String) -> String {
  return urlFormEncode(values: values, rootKey: rootKey, keyConstructor: id)
}

/// Encodes a dictionary of values into `x-www-form-urlencoded` format.
///
/// - Parameter value: The dictionary of values to encode
public func urlFormEncode(value: [String: Any]) -> String {
  return urlFormEncode(value: value, keyConstructor: id)
}

private func urlFormEncode(values: [Any], rootKey: String, keyConstructor: (String) -> String) -> String {
  return values
    .map { value in
      switch value {
      case let value as [String: Any]:
        return urlFormEncode(value: value, keyConstructor: { "\(keyConstructor(rootKey))[][\($0)]" })

      case let values as [Any]:
        return urlFormEncode(value: values, keyConstructor: { _ in "\(keyConstructor(rootKey))[][]" })

      default:
        return urlFormEncode(value: value, keyConstructor: { _ in "\(keyConstructor(rootKey))[]" })
      }
    }
    .joined(separator: "&")
}

private func urlFormEncode(value: Any, keyConstructor: (String) -> String) -> String {
  guard let dictionary = value as? [String: Any] else {
    let encoded = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed) ?? value
    return "\(keyConstructor(""))=\(encoded)"
  }

  return dictionary
    .map { key, value in
      switch value {
      case let value as [String: Any]:
        return urlFormEncode(value: value, keyConstructor: { "\(keyConstructor(key))[\($0)]" })

      case let values as [Any]:
        return urlFormEncode(values: values, rootKey: key, keyConstructor: keyConstructor)

      default:
        return urlFormEncode(value: value, keyConstructor: { _ in keyConstructor(key) })
      }
    }
    .joined(separator: "&")
}

extension CharacterSet {
  // TODO: move to... prelude? swift-web?
  public static let urlQueryParamAllowed = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ^").inverted
}
