import EpisodeModels

extension Episode {
  var slug: String {
    return "ep\(self.sequence)-\(PointFree.slug(for: self.title))"
  }
}

extension Tag {
  var slug: String {
    return PointFree.slug(for: name)
  }

  init?(slug: String) {
    guard let tag = array(Tag.all).first(where: { PointFree.slug(for: slug) == $0.slug })
      else { return nil }
    self = tag
  }
}

private func slug(for string: String) -> String {
  return string.lowercased().replacingOccurrences(of: " ", with: "-")
}
