public struct HTMLGroup<Content: HTML>: HTML {
  let content: Content
  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }
  public var body: some HTML {
    content
  }
}
