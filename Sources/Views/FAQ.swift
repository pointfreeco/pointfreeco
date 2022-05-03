import Ccmark
import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Prelude

struct Faq {
  let question: String
  let answer: String
}

func faq(faqs: [Faq]) -> Node {
  .gridRow(
    attributes: [
      .class([
        Class.padding([.mobile: [.all: 2], .desktop: [.all: 4]])
      ]),
      .style(maxWidth(.px(1080)) <> margin(topBottom: nil, leftRight: .auto)),
    ],
    .gridColumn(
      sizes: [.mobile: 12, .desktop: 8],
      attributes: [.style(margin(leftRight: .auto))],
      .div(
        .h3(
          attributes: [
            .id("faq"),
            .class([
              Class.pf.type.responsiveTitle2,
              Class.grid.center(.desktop),
              Class.padding([.mobile: [.bottom: 2], .desktop: [.bottom: 3]]),
            ]),
          ],
          "FAQ"
        ),
        faqItems(faqs: faqs)
      )
    )
  )
}

func faqItems(faqs: [Faq]) -> Node {
  .fragment(
    faqs.flatMap { faq in
      [
        .p(
          attributes: [
            .class([
              Class.type.bold,
              Class.pf.colors.fg.black,
            ])
          ],
          .text(faq.question)
        ),
        .markdownBlock(
          attributes: [
            .class([
              Class.pf.colors.fg.gray400,
              Class.padding([.mobile: [.bottom: 2]]),
            ])
          ],
          faq.answer,
          options: CMARK_OPT_UNSAFE
        ),
      ]
    }
  )
}
