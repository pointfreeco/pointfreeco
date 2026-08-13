import Dependencies
import Foundation
import Html
import Models
import PointFreeDependencies
import PointFreeRouter
import StyleguideV2

public struct OfficeHoursIndex: HTML {
  let officeHours: [Models.OfficeHour]

  @Dependency(\.date.now) var now
  @Dependency(\.subscriberState) var subscriberState

  public init(officeHours: [Models.OfficeHour]) {
    self.officeHours = officeHours
  }

  var liveOfficeHour: Models.OfficeHour? {
    officeHours.first(where: \.isLive)
  }

  var nextOfficeHour: Models.OfficeHour? {
    officeHours
      .filter { officeHour in
        guard
          !officeHour.isArchived,
          !officeHour.isLive,
          let scheduledAt = officeHour.scheduledAt
        else { return false }
        return scheduledAt > now
      }
      .min { ($0.scheduledAt ?? .distantFuture) < ($1.scheduledAt ?? .distantFuture) }
  }

  var pastOfficeHours: [Models.OfficeHour] {
    officeHours.filter(\.isArchived)
  }

  public var body: some HTML {
    PageHeader(title: "Office Hours") {
      """
      Periodic livestreams exclusively for Point-Free Max subscribers. Bring us your \
      questions about our episodes and libraries and we will discuss them live on the air.
      """
    }

    if let liveOfficeHour {
      if subscriberState.isMaxSubscriber {
        OfficeHoursLiveEmbeds(officeHour: liveOfficeHour)
      } else {
        OfficeHourVideoNotice(
          notice: "🔴 We are live right now!",
          title: liveOfficeHour.title,
          description: liveOfficeHour.description
        )
      }
    } else if let nextOfficeHour, let scheduledAt = nextOfficeHour.scheduledAt {
      OfficeHourVideoNotice(
        notice: "Scheduled for \(officeHoursScheduledAtFormatter.string(from: scheduledAt))",
        title: nextOfficeHour.title,
        description: nextOfficeHour.description
      )
    } else {
      OfficeHourVideoNotice(
        notice: "Nothing on the calendar… yet",
        title: "A new office hour will be scheduled soon",
        description: """
          Check back here, or keep an eye on our newsletter, for the announcement of our \
          next session.
          """
      )
    }

    if !subscriberState.isMaxSubscriber {
      MaxSubscriberCallout()
    }

    if !pastOfficeHours.isEmpty {
      PageModule(title: "Past office hours", theme: .content) {
        VStack(spacing: 3) {
          HTMLForEach(pastOfficeHours) { officeHour in
            PastOfficeHourRow(officeHour: officeHour)
          }
        }
        .inlineStyle("width", "100%")
      }
    }
  }
}

public struct OfficeHourDetail: HTML {
  let officeHour: Models.OfficeHour

  public init(officeHour: Models.OfficeHour) {
    self.officeHour = officeHour
  }

  public var body: some HTML {
    if let cloudflareVideoID = officeHour.cloudflareVideoID {
      VideoHeader(
        title: officeHour.title,
        subtitle: """
          Office Hours • \
          \(headerDateFormatter.string(from: officeHour.scheduledAt ?? officeHour.createdAt))
          """,
        blurb: officeHour.description,
        videoID: cloudflareVideoID,
        poster: officeHour.posterURL,
        progress: nil,
        trackProgress: false
      )
    }
  }
}

private struct OfficeHourVideoNotice: HTML {
  let notice: String
  let title: String
  var description: String?

  var body: some HTML {
    div {
      div {
        VStack(alignment: .center, spacing: 1) {
          span {
            HTMLText(notice)
          }
          .fontStyle(.body(.small))
          .color(.gray650)

          Header(3) {
            HTMLText(title)
          }
          .color(.white)
          .inlineStyle("text-align", "center")
          .inlineStyle("text-wrap", "balance")

          if let description, !description.isEmpty {
            HTMLMarkdown(description)
              .color(.gray800)
              .linkStyle(.init(color: .offWhite, underline: true))
              .inlineStyle("max-width", "36rem")
              .inlineStyle("text-align", "center")
          }
        }
      }
      .inlineStyle("align-items", "center")
      .inlineStyle("aspect-ratio", "16 / 9")
      .inlineStyle("background", "linear-gradient(#1a1a1a, #0a0a0a)")
      .inlineStyle("border", "1px solid #333")
      .inlineStyle("border-radius", "8px")
      .inlineStyle("box-sizing", "border-box")
      .inlineStyle("display", "flex")
      .inlineStyle("justify-content", "center")
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "960px")
      .inlineStyle("overflow", "hidden")
      .inlineStyle("padding", "2rem")
    }
    .backgroundColor(.black)
    .inlineStyle("padding", "2rem 2rem 4rem")
    .inlineStyle("padding", "2rem 3rem 4rem", media: .desktop)
  }
}

private struct PastOfficeHourRow: HTML {
  let officeHour: Models.OfficeHour

  var body: some HTML {
    if let cloudflareVideoID = officeHour.cloudflareVideoID {
      LazyVGrid(
        columns: [.mobile: [1], .desktop: [1, 2]],
        alignItems: .start,
        horizontalSpacing: 2,
        verticalSpacing: 1
      ) {
        Link(destination: .officeHours(.officeHour(cloudflareVideoID: cloudflareVideoID))) {
          Image(source: officeHour.posterURL, description: "")
            .attribute("loading", "lazy")
            .inlineStyle("border-radius", "6px")
            .inlineStyle("width", "100%")
        }
        .inlineStyle("display", "block")
        .inlineStyle("line-height", "0")

        VStack(spacing: 0.5) {
          Header(4) {
            Link(destination: .officeHours(.officeHour(cloudflareVideoID: cloudflareVideoID))) {
              HTMLText(officeHour.title)
            }
            .linkColor(.black.dark(.white))
          }

          span {
            HTMLText(
              headerDateFormatter.string(from: officeHour.scheduledAt ?? officeHour.createdAt)
            )
            if let duration = officeHour.duration {
              " • \(duration.formatted())"
            }
          }
          .fontStyle(.body(.small))
          .color(.gray400.dark(.gray650))

          if !officeHour.blurb.isEmpty {
            HTMLMarkdown(officeHour.blurb)
              .color(.gray400.dark(.gray650))
              .linkStyle(LinkStyle(color: .gray400.dark(.gray650), underline: true))
          }
        }
      }
    }
  }
}

private struct MaxSubscriberCallout: HTML {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    CalloutModule(
      title: "Exclusively for Max subscribers",
      subtitle: """
        Join our live office hours and watch the full archive of past sessions by upgrading \
        to Point-Free Max.
        """,
      ctaTitle: subscriberState.isActiveSubscriber
        ? "Upgrade to Point-Free Max"
        : "Subscribe to Point-Free Max",
      ctaURL: siteRouter.path(for: subscriberState.subscribeToMaxRoute)
    )
  }
}

private struct OfficeHoursLiveEmbeds: HTML {
  let officeHour: Models.OfficeHour

  @Dependency(\.envVars.baseUrl) var baseURL
  @Dependency(\.envVars.youtubeChannelID) var youtubeChannelID

  var body: some HTML {
    div {
      LazyVGrid(
        columns: [.mobile: [1], .desktop: [2, 1]],
        alignItems: .start,
        horizontalSpacing: 0,
        verticalSpacing: 0
      ) {
        OfficeHoursVideoEmbed(youtubeChannelID: youtubeChannelID)
        if !officeHour.videoID.isEmpty {
          OfficeHoursChatEmbed(
            videoID: officeHour.videoID,
            host: baseURL.host() ?? "localhost"
          )
        }
      }
      .inlineStyle("width", "100%")
    }
    .backgroundColor(.black)
    .inlineStyle("padding", "0")
  }
}

private struct OfficeHoursVideoEmbed: HTML {
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

private struct OfficeHoursChatEmbed: HTML {
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

private let officeHoursScheduledAtFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .short
  return df
}()
