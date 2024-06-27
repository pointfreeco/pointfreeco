import StyleguideV2
import Models

public struct Card<Content: HTML, Header: HTML>: HTML {
  let content: Content
  let header: Header

  public init(
    @HTMLBuilder content: () -> Content,
    @HTMLBuilder header: () -> Header = { HTMLEmpty() }
  ) {
    self.content = content()
    self.header = header()
  }

  public var body: some HTML {
    GridColumn {
      header
      div {
        content
      }
      .backgroundColor(.white)
      .inlineStyle("padding", "2rem 2rem 2rem 2rem")
      .inlineStyle("margin", "1rem 1rem 2rem 1rem")
      .inlineStyle("border-radius", "5px")
      .inlineStyle("box-shadow", "0 2px 10px 0 rgba(0,0,0,0.3)")
    }
    .column(count: 12)
    .column(count: 4, media: .desktop)
  }
}

public struct EpisodeCard: HTML {
  let episode: Episode

  public init(_ episode: Episode) {
    self.episode = episode
  }

  public var body: some HTML {
    Card {
      Header(4) {
        HTMLText(episode.title)
      }
      Paragraph {
        HTMLMarkdown(episode.blurb)
      }
      .color(.gray650)
    } header: {
      img()
        .href(episode.image)
        .attribute("alt")
    }
  }
}

import SwiftUI

#Preview {
  NodePreview {
    PageLayout(
      layoutData: SimplePageLayoutData(
        style: .minimal,
        title: ""
      )
    ) {
      Grid {
        HTMLForEach(Episode.all.suffix(3)) { episode in
          EpisodeCard(episode)
        }
      }
    }
  }
  .frame(width: 900, height: 800)
}
