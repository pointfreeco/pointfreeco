import Css
import Dependencies
import Foundation
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeDependencies
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import StyleguideV2

public struct ClipsIndex: HTML {
  let clips: [Models.Clip]

  @Dependency(\.subscriberState) var subscriberState

  public init(clips: [Models.Clip]) {
    self.clips = clips
  }

  public var body: some HTML {
    PageHeader(title: "Point-Free Clips") {
      """
      A collection of some of our favorite moments from Point-Free episodes.
      """
    }
    PageModule(theme: .content) {
      LazyVGrid(columns: [1, 1, 1]) {
        HTMLForEach(clips.prefix(3)) { clip in
          ClipCard(clip)
        }
      }

      if !subscriberState.isActiveSubscriber {
        CenterColumn {
          GetStartedModule(style: .solid)
        }
        .inlineStyle("margin", "2rem 0")
      }

      LazyVGrid(columns: [1, 1, 1]) {
        HTMLForEach(clips.dropFirst(3)) { clip in
          ClipCard(clip)
        }
      }
    }
  }
}

public struct ClipView: HTML {
  let clip: Models.Clip

  @Dependency(\.subscriberState) var subscriberState

  public init(clip: Models.Clip) {
    self.clip = clip
  }

  public var body: some HTML {
    VideoHeader(
      title: clip.title,
      subtitle: """
        Episode Clip • \(headerDateFormatter.string(from: clip.createdAt))
        """,
      blurb: clip.description,
      videoID: .vimeo(clip.vimeoVideoID),
      poster: clip.posterURL,
      progress: nil,
      trackProgress: false
    )

    if !subscriberState.isActiveSubscriber {
      CenterColumn {
        GetStartedModule(style: .solid)
      }
      .inlineStyle("padding-bottom", "4rem")
    }
  }
}

#if DEBUG && canImport(SwiftUI)
  import SwiftUI
  import Transcripts

  #Preview("Clips Index", traits: .fixedLayout(width: 800, height: 1000)) {
    HTMLPreview {
      PageLayout(layoutData: SimplePageLayoutData(title: "")) {
        ClipsIndex(
          clips: [
            .mock,
            .mock,
            .mock,
            .mock,
          ]
        )
      }
    }
  }

  #Preview("Clip Show", traits: .fixedLayout(width: 800, height: 1000)) {
    HTMLPreview {
      PageLayout(layoutData: SimplePageLayoutData(title: "")) {
        ClipView(clip: .mock)
      }
    }
  }

  extension Models.Clip {
    fileprivate static var mock: Self {
      Models.Clip(
        id: Clip.ID(UUID()),
        blurb: """
          We often need to perform async work when there is no async context, such as in SwiftUI button action closures. In such cases it seems that you have no choice but to spin up an unstructured Task, but you may have heard that doing so it bad. So what are you to do? Well, there is an easy answer…
          """,
        createdAt: Date(),
        description: """
          We often need to perform async work when there is no async context, such as in SwiftUI button action closures. In such cases it seems that you have no choice but to spin up an unstructured Task, but you may have heard that doing so it bad. So what are you to do? Well, there is an easy answer…
          """,
        duration: 300,
        order: 1,
        posterURL:
          "https://i.vimeocdn.com/video/1864209432-b580f900f7a12b935e0e8c7028c124b5d15c8f80efb688445312650c9b973910-d",
        title: "How should you perform async work in a non-async context?",
        vimeoVideoID: 790_482_468
      )
    }
  }
#endif
