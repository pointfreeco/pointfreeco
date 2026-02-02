import Dependencies
import Foundation
import Models
import PointFreeRouter
import StyleguideV2

public struct LiveView: HTML {
  @Dependency(\.envVars.baseUrl) var baseURL
  @Dependency(\.envVars.youtubeChannelID) var youtubeChannelID
  @Dependency(\.livestreams) var livestreams

  public init() {}

  public var body: some HTML {
    if let activeLivestream = livestreams.first(where: \.isActive) {
      VStack(spacing: 0) {
        LiveHeader(livestream: activeLivestream)
        LiveEmbeds(
          youtubeChannelID: youtubeChannelID,
          videoID: activeLivestream.videoID,
          host: baseURL.host() ?? "localhost"
        )
      }
    } else {
      HTMLEmpty()
    }
  }
}

private struct LiveHeader: HTML {
  let livestream: Livestream

  var body: some HTML {
    CenterColumn {
      VStack(alignment: .center, spacing: 1) {
        Header(2) {
          HTMLRaw(nonBreaking(title: livestream.title))
        }
        .color(.white)
        .inlineStyle("text-align", "center")
        .inlineStyle("text-wrap", "balance")

        LiveDate(livestream: livestream)

        HTMLMarkdown(description)
          .color(.gray900)
          .inlineStyle("max-width", "768px")
          .inlineStyle("margin", "0 auto")
          .inlineStyle("text-align", "left")
          .linkStyle(.init(color: .offWhite, underline: true))
      }
      .inlineStyle("padding", "3rem 2rem 2rem")
      .inlineStyle("padding", "4rem 3rem 3rem", media: .desktop)
    }
    .inlineStyle("background", "linear-gradient(#121212, #242424)")

    LiveCallToAction(livestream: livestream)
      .inlineStyle("padding", "0 2rem 3rem")
      .inlineStyle("padding", "0 3rem 3rem", media: .desktop)
      .inlineStyle("background", "linear-gradient(#242424, #0a0a0a)")
  }

  private var description: String {
    if livestream.isLive {
      return livestream.liveDescription ?? livestream.description
    } else {
      return livestream.description
    }
  }
}

private struct LiveDate: HTML {
  let livestream: Livestream

  var body: some HTML {
    if let scheduledAt = livestream.scheduledAt {
      HStack(alignment: .center, spacing: 0.5) {
        if livestream.isLive {
          span { "🔴" }
            .inlineStyle("animation", "Pulse 3s linear infinite")
        }
        if livestream.isLive {
          "We are live right now!"
        } else {
          "Scheduled for \(livestreamScheduledAtFormatter.string(from: scheduledAt))"
        }
      }
      .fontStyle(.body(.small))
      .color(.gray650)
      .inlineStyle("text-align", "center")
    }
  }
}

private struct LiveCallToAction: HTML {
  let livestream: Livestream

  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    if currentUser == nil, !livestream.isLive {
      CenterColumn {
        div {
          Button(color: .white, size: .regular) {
            "Log in to be notified"
          }
          .attribute("href", siteRouter.loginPath(redirect: currentRoute))
        }
        .inlineStyle("text-align", "center")
      }
    } else if currentUser != nil {
      CenterColumn {
        div {
          Button(color: .purple, size: .regular) {
            "Watch on YouTube →"
          }
          .attribute("href", "https://youtube.com/live/\(livestream.videoID)")
        }
        .inlineStyle("text-align", "center")
      }
    }
  }
}

private struct LiveEmbeds: HTML {
  let youtubeChannelID: String
  let videoID: String
  let host: String

  var body: some HTML {
    div {
      LazyVGrid(
        columns: [.mobile: [1], .desktop: [2, 1]],
        alignItems: .start,
        horizontalSpacing: 0,
        verticalSpacing: 0
      ) {
        LiveVideoEmbed(youtubeChannelID: youtubeChannelID)
        LiveChatEmbed(videoID: videoID, host: host)
      }
      .inlineStyle("width", "100%")
    }
    .backgroundColor(.black)
    .inlineStyle("padding", "0")
  }
}

private struct LiveVideoEmbed: HTML {
  let youtubeChannelID: String

  var body: some HTML {
    div {
      iframe()
        .attribute(
          "src",
          "https://www.youtube.com/embed/live_stream?channel=\(youtubeChannelID)"
        )
        .attribute("allow", "autoplay; fullscreen; picture-in-picture")
        .attribute("allowfullscreen")
        .attribute("loading", "lazy")
        .inlineStyle("border", "none")
        .inlineStyle("position", "absolute")
        .inlineStyle("top", "0")
        .inlineStyle("left", "0")
        .inlineStyle("width", "100%")
        .inlineStyle("height", "100%")
    }
    .inlineStyle("background", "#000")
    .inlineStyle("height", "0")
    .inlineStyle("overflow", "hidden")
    .inlineStyle("padding-bottom", "56.25%")
    .inlineStyle("position", "relative")
  }
}

private struct LiveChatEmbed: HTML {
  let videoID: String
  let host: String

  var body: some HTML {
    div {
      iframe()
        .attribute("src", "https://www.youtube.com/live_chat?v=\(videoID)&embed_domain=\(host)")
        .attribute("loading", "lazy")
        .attribute("frameborder", "0")
        .inlineStyle("border", "none")
        .inlineStyle("width", "100%")
        .inlineStyle("height", "100%")
        .inlineStyle("min-height", "40rem")
    }
    .inlineStyle("background", "#000")
    .inlineStyle("min-height", "40rem")
    .inlineStyle("overflow", "hidden")
  }
}

private let livestreamScheduledAtFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .none
  return df
}()

private func nonBreaking(title: String) -> String {
  let parts = title.components(separatedBy: ": ")
  guard
    parts.count == 2,
    let mainTitle = parts.first,
    let subTitle = parts.last
  else { return title }

  let nonBreakingSubtitle = subTitle.components(separatedBy: ", ")
    .map { $0.replacingOccurrences(of: " ", with: "&nbsp;") }
    .joined(separator: ", ")

  return mainTitle + ": " + nonBreakingSubtitle
}
