import Models
import StyleguideV2

public struct NewsletterDetail: HTML {
  let blogPost: BlogPost

  public init(blogPost: BlogPost) {
    self.blogPost = blogPost
  }

  public var body: some HTML {
    PageModule(
      title: blogPost.title,
      theme: .content
    ) {
      VStack(spacing: 3) {
        div {
          HTMLText(blogPost.publishedAt.weekdayMonthDayYear())
        }
        .color(.gray500)
        .inlineStyle("text-align", "center")
        .inlineStyle("width", "100%")

        if let content = blogPost.content {
          HTMLMarkdown(content)
        }

//        for block in blogPost.contentBlocks {
//          switch block.type {
//          case .box(let box):
//            HTMLEmpty()
//          case .button(let href):
//            HTMLEmpty()
//          case .code(let lang):
//            HTMLEmpty()
//          case .image(let src, let sizing):
//            HTMLEmpty()
//          case .paragraph:
//            HTMLMarkdown(block.content)
//          case .question(let string):
//            HTMLEmpty()
//          case .title:
//            Header(1) {
//              HTMLText(block.content)
//            }
//          case .video(let poster, let sources):
//            HTMLEmpty()
//          }
//        }
      }
      .inlineStyle("margin", "0 auto", media: .desktop)
      .inlineStyle("width", "60%", media: .desktop)
    }
  }
}

#if canImport(SwiftUI)
  import SwiftUI
  import Transcripts

  #Preview {
    HTMLPreview {
      PageLayout(layoutData: SimplePageLayoutData(title: "")) {
        NewsletterDetail(blogPost: post0129_Perception)
      }
    }
    .frame(width: 1280)
  }
#endif
