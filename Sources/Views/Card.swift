import StyleguideV2
import Dependencies
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
  @Dependency(\.date.now) var now

  let episode: Episode
  let emergencyMode: Bool

  public init(_ episode: Episode, emergencyMode: Bool) {
    self.episode = episode
    self.emergencyMode = emergencyMode
  }

  public var body: some HTML {
    Card {
      Header(4) {
        HTMLText(episode.title)
      }

      HTMLMarkdown(episode.blurb)
        .color(.gray650)

      Grid {
        if episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) {
          SVG.locked
          "Subscriber-only"
        } else {
          SVG.unlocked
          "Free"
        }
      }
      .grid(alignment: .center)
      .color(.gray650)

    } header: {
      img()
        .href(episode.image)
        .attribute("alt")
    }
  }
}

extension SVG {
  static let locked = Self("Subscriber-only") {
    """
    <svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M12 5.83342H11.3334V4.50008C11.3334 2.66008 9.84002 1.16675 8.00002 1.16675C6.16002 1.16675 4.66669 2.66008 4.66669 4.50008V5.83342H4.00002C3.26669 5.83342 2.66669 6.43341 2.66669 7.16675V13.8334C2.66669 14.5667 3.26669 15.1667 4.00002 15.1667H12C12.7334 15.1667 13.3334 14.5667 13.3334 13.8334V7.16675C13.3334 6.43341 12.7334 5.83342 12 5.83342ZM7.99994 11.8335C7.26661 11.8335 6.66661 11.2335 6.66661 10.5001C6.66661 9.76679 7.26661 9.16679 7.99994 9.16679C8.73327 9.16679 9.33327 9.76679 9.33327 10.5001C9.33327 11.2335 8.73327 11.8335 7.99994 11.8335ZM10.0665 5.83347H5.93321V4.50014C5.93321 3.36014 6.85987 2.43347 7.99987 2.43347C9.13987 2.43347 10.0665 3.36014 10.0665 4.50014V5.83347Z" fill="#7D7D7D"/>
    </svg>
    """
  }

  static let unlocked = Self("Free") {
    """
    <svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M8.49996 11.8333C9.23329 11.8333 9.83329 11.2333 9.83329 10.5C9.83329 9.76666 9.23329 9.16666 8.49996 9.16666C7.76663 9.16666 7.16663 9.76666 7.16663 10.5C7.16663 11.2333 7.76663 11.8333 8.49996 11.8333ZM12.5 5.83332H11.8333V4.49999C11.8333 2.65999 10.34 1.16666 8.49996 1.16666C6.65996 1.16666 5.16663 2.65999 5.16663 4.49999H6.43329C6.43329 3.35999 7.35996 2.43332 8.49996 2.43332C9.63996 2.43332 10.5666 3.35999 10.5666 4.49999V5.83332H4.49996C3.76663 5.83332 3.16663 6.43332 3.16663 7.16666V13.8333C3.16663 14.5667 3.76663 15.1667 4.49996 15.1667H12.5C13.2333 15.1667 13.8333 14.5667 13.8333 13.8333V7.16666C13.8333 6.43332 13.2333 5.83332 12.5 5.83332ZM12.5 13.8333H4.49996V7.16666H12.5V13.8333Z" fill="#7D7D7D"/>
    </svg>
    """
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
        HTMLForEach(Episode.all.dropLast(5).suffix(3)) { episode in
          EpisodeCard(episode, emergencyMode: false)
        }
      }
    }
  }
  .frame(width: 900, height: 800)
}
