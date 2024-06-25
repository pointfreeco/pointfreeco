struct PageLayout<Content: HTML>: HTMLDocument {
  let pageTitle: String
  @HTMLBuilder let content: Content

  var head: some HTML {
    title { pageTitle }
  }

  var body: some HTML {
    main {
      content
    }
  }
}
