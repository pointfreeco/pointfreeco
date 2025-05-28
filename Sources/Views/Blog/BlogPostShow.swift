import Dependencies
import Models
import StyleguideV2

public struct NewsletterDetail: HTML {
  @Dependency(\.currentUser) var currentUser

  var blogPost: BlogPost
  // TODO: Link to previous/next posts
  var previousBlogPost: BlogPost?
  var nextBlogPost: BlogPost?

  public init(blogPost: BlogPost) {
    self.blogPost = blogPost
  }

  public var body: some HTML {
    NewsletterDetailModule(blogPost: blogPost)

    if currentUser == nil {
      GetStartedModule(style: .gradient)
    }
  }
}

struct NewsletterDetailModule: HTML {
  var blogPost: BlogPost

  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.date.now) var now
  @Dependency(\.episodes) var episodes
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    PageModule(theme: .content) {
      VStack(spacing: 3) {
        if !subscriberState.isActiveSubscriber {
          let freeEpisodeCount = episodes().count(
            where: {
              !$0.isSubscriberOnly(
                currentDate: now,
                emergencyMode: emergencyMode
              )
            }
          )
          CalloutModule(
            title: "Find this interesting?",
            subtitle: """
                        Get started with our free plan, which includes **1 subscriber-only** episode of your \
                        choice, access to **\(freeEpisodeCount) free** episodes with transcripts and code \
                        samples, and weekly updates from our newsletter.
                        """,
            ctaTitle: "Sign up for free →",
            ctaURL: siteRouter.path(
              for: .auth(.signUp(redirect: siteRouter.url(for: currentRoute)))
            ),
            secondaryCTATitle: "View plans and pricing",
            secondaryCTAURL: siteRouter.path(for: .pricingLanding),
            backgroundColor: PointFreeColor(rawValue: "#e6f9f1", darkValue: "#0f1f1b")
          )
        }
        if let content = blogPost.content {
          article {
            HTMLMarkdown(content)
              .color(.gray150.dark(.gray800))
              .linkColor(.black.dark(.white))
              .linkUnderline(true)
          }
        }
      }
      .inlineStyle("margin", "0 auto", media: .desktop)
      .inlineStyle("width", "75%", media: .desktop)
    } title: {
      VStack {
        Link(destination: .blog(.show(.left(blogPost.slug)))) {
          Header(3) {
            HTMLMarkdown(blogPost.title)
          }
        }
        .linkColor(.offBlack.dark(.offWhite))

        div {
          HTMLText(blogPost.publishedAt.weekdayMonthDayYear())
        }
        .color(.gray500)
      }
      .inlineStyle("text-align", "center")
      .inlineStyle("width", "100%")
    }
  }
}

#if canImport(SwiftUI)
  import SwiftUI
  import Transcripts

  #Preview {
    HTMLPreview {
      PageLayout(layoutData: SimplePageLayoutData(title: "")) {
        NewsletterDetail(blogPost: .post0129_Perception)
      }
    }
    .frame(width: 1280)
  }
#endif
