import Dependencies
import Models
import StyleguideV2

public struct NewsletterDetail: HTML {
  @Dependency(\.currentUser) var currentUser

  var blogPost: BlogPost
  var previousBlogPost: BlogPost?
  var nextBlogPost: BlogPost?

  public init(blogPost: BlogPost) {
    self.blogPost = blogPost
  }

  public var body: some HTML {
    style {
      """
      article > pf-markdown > pf-vstack > :last-child::after {
        margin: 0 0.5rem;
        content: "❖";
      }
      """
    }

    PageModule(theme: .content) {
      VStack(spacing: 3) {
        if let content = blogPost.content {
          article {
            HTMLMarkdown(content)
              .color(.gray150.dark(.gray800))
              .linkColor(.black.dark(.white))
              .linkUnderline(true)
          }
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
    } title: {
      VStack {
        Header(3) {
          HTMLMarkdown(blogPost.title)
        }

        div {
          HTMLText(blogPost.publishedAt.weekdayMonthDayYear())
        }
        .color(.gray500)
      }
      .inlineStyle("text-align", "center")
      .inlineStyle("width", "100%")
    }

    if currentUser == nil {
      GetStartedModule(style: .gradient)
    }
  }
}

import Markdown

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
