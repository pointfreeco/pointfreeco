import StyleguideV2

struct FAQModule: HTML {
  let faqs: [Faq]
  var body: some HTML {
    PageModule(title: "FAQ", theme: .content) {
      VStack(spacing: 3) {
        HTMLForEach(faqs) { faq in
          div {
            Header(4) {
              HTMLText(faq.question)
            }
            .color(.black.dark(.offWhite))

            HTMLMarkdown(faq.answer)
          }
        }
      }
      .color(.gray300.dark(.gray850))
      .linkColor(.gray150.dark(.gray900))
      .linkUnderline(true)
      .inlineStyle("margin", "0 auto")
      .inlineStyle("width", "60%", media: .desktop)
    }
  }
}
