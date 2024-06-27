public struct Image: HTML {
  let source: String
  let description: String

  public init(source: String, description: String) {
    self.source = source
    self.description = description
  }

  public var body: some HTML {
    img()
      .attribute("src", source)
      .attribute("alt", description)
  }
}
