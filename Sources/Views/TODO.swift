import Html

public func playsinline(_ value: Bool) -> Attribute<Tag.Video> {
  return .init("playslinline", value ? "" : nil)
}
