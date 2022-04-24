import UrlFormEncoding

let formDecoder: UrlFormDecoder = {
  let decoder = UrlFormDecoder()
  decoder.parsingStrategy = .bracketsWithIndices
  return decoder
}()

func slug(for string: String) -> String {
  string
    .lowercased()
    .replacingOccurrences(of: "[\\W]+", with: "-", options: .regularExpression)
    .replacingOccurrences(of: "\\A-|-\\z", with: "", options: .regularExpression)
}
