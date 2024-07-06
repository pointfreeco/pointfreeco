import Dependencies
import Models
import StyleguideV2

public struct EpisodeCard: HTML {
  @Dependency(\.date.now) var now
  @Dependency(\.envVars.emergencyMode) var emergencyMode
  @Dependency(\.episodeProgresses) var episodeProgresses
  @Dependency(\.subscriberState) var subscriberState

  let episode: Episode

  public init(_ episode: Episode) {
    self.episode = episode
  }

  public var body: some HTML {
    Card {
      VStack {
        VStack(spacing: 0.5) {
          div {
            "Episode \(episode.sequence.rawValue) • \(episode.publishedAt.monthDayYear())"
          }
          .color(.gray650.dark(.gray400))
          .fontStyle(.body(.small))

          div {
            Header(4) {
              Link(destination: .episodes(.show(episode))) {
                HTMLText(episode.title)
                if let subtitle = episode.subtitle {
                  ":"
                  br()
                  HTMLText(subtitle)
                }
              }
              .linkColor(.black.dark(.white))
            }
          }
        }

        HTMLMarkdown(episode.blurb)
          .color(.gray400.dark(.gray650))
          .linkStyle(LinkStyle(color: .gray400.dark(.gray650), underline: true))
      }
    } header: {
      Link(destination: .episodes(.show(episode))) {
        Image(source: episode.image, description: "")
          .attribute("loading", "lazy")
          .inlineStyle("width", "100%")
          .inlineStyle("filter", progress?.isFinished == true ? "grayscale(1)" : nil)
      }
      .inlineStyle("display", "block")
      .inlineStyle("line-height", "0")
    } footer: {
      CardFooter {
        if episode.isSubscriberOnly(currentDate: now, emergencyMode: emergencyMode) {
          if !subscriberState.isActive {
            Link(destination: .pricingLanding) {
              Label("Subscriber-only", icon: .locked)
            }
            .linkColor(.currentColor)
          }
        } else {
          Label("Free", icon: .unlocked)
        }

        Label(episode.length.formatted(), icon: .clock)
          .grow()

        if let progress {
          if progress.isFinished {
            Label("Watched", icon: .checkmark)
          } else {
            let value = Double(progress.percent) / 100
            let minutes = (episode.length.timeInterval - episode.length.timeInterval * value) / 60

            Progress(value: value)
              .inlineStyle("width", "80px")
              .attribute("title", "\(Int(minutes)) min to finish")
          }
        }
      }
    }
  }

  var progress: EpisodeProgress? {
    episodeProgresses[episode.sequence]
  }
}

public struct Progress: HTML {
  let value: Double

  init(value: Double) {
    self.value = value
  }

  public var body: some HTML {
    div {
      div {}
        .backgroundColor(.gray300.dark(.gray650))
        .inlineStyle("height", "100%")
        .inlineStyle("width", "\(Int(value * 100))%")
    }
    .backgroundColor(.gray850.dark(.gray300))
    .inlineStyle("border-radius", "4px")
    .inlineStyle("display", "inline-block")
    .inlineStyle("height", "8px")
    .inlineStyle("overflow", "hidden")
  }
}

public struct ClipCard: HTML {
  @Dependency(\.date.now) var now

  let clip: Clip

  public init(_ clip: Clip) {
    self.clip = clip
  }

  public var body: some HTML {
    Card {
      Header(4) {
        Link(destination: .clips(.clip(videoID: clip.vimeoVideoID))) {
          HTMLText(clip.title)
        }
        .linkColor(.black.dark(.white))
      }

      HTMLMarkdown(clip.blurb)
        .color(.gray400.dark(.gray650))
        .linkStyle(LinkStyle(color: .gray400.dark(.gray650), underline: true))
        .inlineStyle("margin-top", "1rem")
    } header: {
      Link(destination: .clips(.clip(videoID: clip.vimeoVideoID))) {
        Image(source: clip.posterURL, description: "")
          .attribute("loading", "lazy")
          .inlineStyle("width", "100%")
      }
      .inlineStyle("display", "block")
      .inlineStyle("line-height", "0")
    } footer: {
      CardFooter {
        Label("Watch", icon: .play)
        Label(clip.duration.formatted(), icon: .clock)
      }
    }
  }
}

public struct CollectionCard: HTML {
  private static let colors = ["#4cccff", "#79f2b0", "#fff080", "#974dff"]
  private static let combos =
    colors
    .flatMap { color in colors.map { (color, $0) } }
    .filter { $0 != $1 }

  let collection: Episode.Collection
  let index: Int

  public init(_ collection: Episode.Collection, index: Int) {
    self.collection = collection
    self.index = index
  }

  public var body: some HTML {
    Card {
      div {
        HTMLMarkdown(collection.blurb)
      }
      .color(.gray400.dark(.gray650))
      .linkStyle(LinkStyle(color: .gray400.dark(.gray650), underline: true))
    } header: {
      Link(destination: .collections(.collection(collection.slug))) {
        let (start, stop) = Self.combos[index % Self.combos.count]

        SVG.collection(linearGradientStart: start, stop: stop)
        div {
          Header(4) {
            HTMLText(collection.title)
          }

          div {
            "Collection"
          }
          .color(.gray650.dark(.gray400))
          .fontStyle(.body(.small))
        }
      }
      .linkStyle(LinkStyle(color: .black.dark(.white), underline: false))
      .inlineStyle("display", "block")
      .inlineStyle("padding", "2rem 1.5rem")
      .inlineStyle("text-align", "center")
    } footer: {
      CardFooter {
        Label("\(collection.numberOfEpisodes) episodes", icon: .play)

        Label(collection.length.formatted(), icon: .clock)
      }
    }
  }
}

private struct CardFooter<Content: HTML>: HTML {
  @HTMLBuilder let content: Content
  var body: some HTML {
    HStack(alignment: .center) {
      content
    }
    .color(.gray650.dark(.gray400))
    .linkColor(.gray650.dark(.gray400))
  }
}

extension SVG {
  static let checkmark = Self("Finished") {
    """
    <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor">
    <path d="M389-267 195-460l51-52 143 143 325-324 51 51-376 375Z"/>
    </svg>
    """
  }

  static func collection(linearGradientStart start: String, stop: String) -> Self {
    Self("Collection") {
      """
      <svg width="65" height="64" viewBox="0 0 65 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="0.5" width="64" height="64" rx="32" fill="url(#paint0_linear_733_2369)"/>
      <path fill-rule="evenodd" clip-rule="evenodd" d="M35.5 17.0259L50.474 31.9999L35.5 46.9739L20.526 31.9999L35.5 17.0259ZM33.0043 34.4956C34.3178 35.8091 36.5883 35.9029 37.9957 34.4956C39.4218 33.0695 39.3092 30.8177 37.9957 29.5042C36.6822 28.1907 34.4304 28.0781 33.0043 29.5042C31.597 30.9116 31.6908 33.1821 33.0043 34.4956ZM29.5883 17.1141L31.0883 18.6141L17.6143 32.0881L31.0883 45.5622L29.5883 47.0622L14.6143 32.0881L29.5883 17.1141Z" fill="white"/>
      <defs>
      <linearGradient id="paint0_linear_733_2369" x1="0.5" y1="0" x2="64.5" y2="64" gradientUnits="userSpaceOnUse">
      <stop stop-color="\(start)"/>
      <stop offset="1" stop-color="\(stop)"/>
      </linearGradient>
      </defs>
      </svg>
      """
    }
  }

  static let locked = Self("Subscriber-only") {
    """
    <svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M12 5.83342H11.3334V4.50008C11.3334 2.66008 9.84002 1.16675 8.00002 1.16675C6.16002 1.16675 4.66669 2.66008 4.66669 4.50008V5.83342H4.00002C3.26669 5.83342 2.66669 6.43341 2.66669 7.16675V13.8334C2.66669 14.5667 3.26669 15.1667 4.00002 15.1667H12C12.7334 15.1667 13.3334 14.5667 13.3334 13.8334V7.16675C13.3334 6.43341 12.7334 5.83342 12 5.83342ZM7.99994 11.8335C7.26661 11.8335 6.66661 11.2335 6.66661 10.5001C6.66661 9.76679 7.26661 9.16679 7.99994 9.16679C8.73327 9.16679 9.33327 9.76679 9.33327 10.5001C9.33327 11.2335 8.73327 11.8335 7.99994 11.8335ZM10.0665 5.83347H5.93321V4.50014C5.93321 3.36014 6.85987 2.43347 7.99987 2.43347C9.13987 2.43347 10.0665 3.36014 10.0665 4.50014V5.83347Z" fill="currentColor"/>
    </svg>
    """
  }

  static let unlocked = Self("Free") {
    """
    <svg width="17" height="17" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M8.49996 11.8333C9.23329 11.8333 9.83329 11.2333 9.83329 10.5C9.83329 9.76666 9.23329 9.16666 8.49996 9.16666C7.76663 9.16666 7.16663 9.76666 7.16663 10.5C7.16663 11.2333 7.76663 11.8333 8.49996 11.8333ZM12.5 5.83332H11.8333V4.49999C11.8333 2.65999 10.34 1.16666 8.49996 1.16666C6.65996 1.16666 5.16663 2.65999 5.16663 4.49999H6.43329C6.43329 3.35999 7.35996 2.43332 8.49996 2.43332C9.63996 2.43332 10.5666 3.35999 10.5666 4.49999V5.83332H4.49996C3.76663 5.83332 3.16663 6.43332 3.16663 7.16666V13.8333C3.16663 14.5667 3.76663 15.1667 4.49996 15.1667H12.5C13.2333 15.1667 13.8333 14.5667 13.8333 13.8333V7.16666C13.8333 6.43332 13.2333 5.83332 12.5 5.83332ZM12.5 13.8333H4.49996V7.16666H12.5V13.8333Z" fill="currentColor"/>
    </svg>
    """
  }

  static let play = Self("Play") {
    """
    <svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M6.66665 11.4999L10.6666 8.49992L6.66665 5.49992V11.4999ZM7.99998 1.83325C4.31998 1.83325 1.33331 4.81992 1.33331 8.49992C1.33331 12.1799 4.31998 15.1666 7.99998 15.1666C11.68 15.1666 14.6666 12.1799 14.6666 8.49992C14.6666 4.81992 11.68 1.83325 7.99998 1.83325ZM7.99998 13.8333C5.05998 13.8333 2.66665 11.4399 2.66665 8.49992C2.66665 5.55992 5.05998 3.16659 7.99998 3.16659C10.94 3.16659 13.3333 5.55992 13.3333 8.49992C13.3333 11.4399 10.94 13.8333 7.99998 13.8333Z" fill="currentColor"/>
    </svg>
    """
  }

  static let clock = Self("Running time") {
    """
    <svg width="16" height="17" viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M7.99331 1.83334C4.31331 1.83334 1.33331 4.82001 1.33331 8.50001C1.33331 12.18 4.31331 15.1667 7.99331 15.1667C11.68 15.1667 14.6666 12.18 14.6666 8.50001C14.6666 4.82001 11.68 1.83334 7.99331 1.83334ZM7.99998 13.8333C5.05331 13.8333 2.66665 11.4467 2.66665 8.50001C2.66665 5.55334 5.05331 3.16668 7.99998 3.16668C10.9466 3.16668 13.3333 5.55334 13.3333 8.50001C13.3333 11.4467 10.9466 13.8333 7.99998 13.8333ZM7.33331 5.16668H8.33331V8.66668L11.3333 10.4467L10.8333 11.2667L7.33331 9.16668V5.16668Z" fill="currentColor"/>
    </svg>
    """
  }

  static let gitHubIcon = Self("GitHub") {
    """
    <svg width="21" height="19" viewBox="0 0 21 19" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path fill-rule="evenodd" clip-rule="evenodd" d="M10.4991 0C4.97773 0 0.5 4.3609 0.5 9.74072C0.5 14.0442 3.36504 17.6947 7.33876 18.9827C7.83908 19.0724 8.02141 18.7717 8.02141 18.5133C8.02141 18.2819 8.01281 17.6696 8.0079 16.857C5.22636 17.4454 4.63948 15.5511 4.63948 15.5511C4.18458 14.4257 3.52894 14.1261 3.52894 14.1261C2.621 13.5222 3.5977 13.5342 3.5977 13.5342C4.60142 13.6029 5.12936 14.5381 5.12936 14.5381C6.02135 16.0264 7.47013 15.5965 8.03983 15.3472C8.13068 14.7181 8.38913 14.2888 8.67459 14.0454C6.45414 13.7996 4.11951 12.9637 4.11951 9.23126C4.11951 8.16809 4.50933 7.29806 5.14901 6.61759C5.04587 6.37123 4.70271 5.38042 5.24723 4.0398C5.24723 4.0398 6.08642 3.77789 7.99685 5.03838C8.7943 4.82192 9.65007 4.71429 10.5003 4.71011C11.3499 4.71429 12.2051 4.82192 13.0038 5.03838C14.913 3.77789 15.7509 4.0398 15.7509 4.0398C16.2967 5.38042 15.9535 6.37123 15.851 6.61759C16.4919 7.29806 16.8786 8.16809 16.8786 9.23126C16.8786 12.9733 14.5403 13.7967 12.3131 14.0376C12.6716 14.3384 12.9915 14.9328 12.9915 15.8411C12.9915 17.1434 12.9792 18.194 12.9792 18.5133C12.9792 18.7741 13.1597 19.0772 13.6668 18.9821C17.6374 17.6912 20.5 14.043 20.5 9.74072C20.5 4.3609 16.0223 0 10.4991 0Z" fill="white"/>
    </svg>
    """
  }
}
