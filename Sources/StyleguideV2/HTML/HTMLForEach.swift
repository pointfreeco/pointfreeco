// NB: Work around a bug in `buildArray` that causes build failures when the element is `some HTML`.
public struct HTMLForEach<Content: HTML>: HTML {
  let content: _HTMLArray<Content>

  public init<Data: RandomAccessCollection>(
    _ data: Data,
    @HTMLBuilder content: (Data.Element) -> Content
  ) {
    self.content = HTMLBuilder.buildArray(data.map(content))
  }

  public var body: some HTML {
    content
  }
}
