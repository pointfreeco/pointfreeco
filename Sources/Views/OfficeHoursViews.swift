import Cloudflare
import Dependencies
import Foundation
import Html
import Models
import PointFreeDependencies
import PointFreeRouter
import StyleguideV2
import Tagged
import TaggedTime

public struct OfficeHoursIndex: HTML {
  let officeHours: [Models.OfficeHour]
  let selectedTab: OfficeHoursRoute.Tab
  let unansweredQuestions: [Models.OfficeHourQuestion]
  let answeredQuestions: [Models.OfficeHour.ID: [Models.OfficeHourQuestion]]

  @Dependency(\.date.now) var now
  @Dependency(\.subscriberState) var subscriberState

  public init(
    officeHours: [Models.OfficeHour],
    selectedTab: OfficeHoursRoute.Tab = .pastOfficeHours,
    unansweredQuestions: [Models.OfficeHourQuestion] = [],
    answeredQuestions: [Models.OfficeHour.ID: [Models.OfficeHourQuestion]] = [:]
  ) {
    self.officeHours = officeHours
    self.selectedTab = selectedTab
    self.unansweredQuestions = unansweredQuestions
    self.answeredQuestions = answeredQuestions
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

    OfficeHoursTabs(
      selectedTab: selectedTab,
      pastOfficeHours: pastOfficeHours,
      unansweredQuestions: unansweredQuestions,
      answeredQuestions: answeredQuestions
    )
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

// MARK: - Tabs

private let officeHoursPastTabInputID = "office-hours-tab-past"
private let officeHoursQATabInputID = "office-hours-tab-qa"
private let officeHoursTabsContentClass = "office-hours-tabs-content"
private let qaTabCheckedSelector =
  "#\(officeHoursQATabInputID):checked ~ .\(officeHoursTabsContentClass)"

private struct OfficeHoursTabs: HTML {
  let selectedTab: OfficeHoursRoute.Tab
  let pastOfficeHours: [Models.OfficeHour]
  let unansweredQuestions: [Models.OfficeHourQuestion]
  let answeredQuestions: [Models.OfficeHour.ID: [Models.OfficeHourQuestion]]

  var body: some HTML {
    PageModule(theme: .content) {
      div {
        input()
          .attribute("id", officeHoursPastTabInputID)
          .attribute("type", "radio")
          .attribute("name", "office-hours-tab")
          .attribute("checked", selectedTab == .pastOfficeHours ? "" : nil)
          .inlineStyle("opacity", "0")
          .inlineStyle("pointer-events", "none")
          .inlineStyle("position", "absolute")

        input()
          .attribute("id", officeHoursQATabInputID)
          .attribute("type", "radio")
          .attribute("name", "office-hours-tab")
          .attribute("checked", selectedTab == .qa ? "" : nil)
          .inlineStyle("opacity", "0")
          .inlineStyle("pointer-events", "none")
          .inlineStyle("position", "absolute")

        div {
          HStack(alignment: .center, spacing: 0.25) {
            TabLabel(
              title: "Past office hours",
              inputID: officeHoursPastTabInputID,
              isActiveWhenQAUnchecked: true
            )
            TabLabel(
              title: "Q&A",
              inputID: officeHoursQATabInputID,
              isActiveWhenQAUnchecked: false
            )
          }
          .inlineStyle("justify-content", "center")
          .inlineStyle("margin-bottom", "3rem")

          div {
            PastOfficeHoursList(
              pastOfficeHours: pastOfficeHours,
              answeredQuestions: answeredQuestions
            )
          }
          .inlineStyle("display", "none", pre: qaTabCheckedSelector)

          div {
            QuestionsSection(questions: unansweredQuestions)
          }
          .inlineStyle("display", "none")
          .inlineStyle("display", "block", pre: qaTabCheckedSelector)
        }
        .attribute("class", officeHoursTabsContentClass)
      }
      .inlineStyle("width", "100%")
    }
  }
}

private struct TabLabel: HTML {
  let title: String
  let inputID: String
  let isActiveWhenQAUnchecked: Bool

  var body: some HTML {
    let active = isActiveWhenQAUnchecked
    label { HTMLText(title) }
      .attribute("for", inputID)
      .inlineStyle("background-color", active ? "#111" : "transparent")
      .inlineStyle("background-color", active ? "#fff" : "transparent", media: .dark)
      .inlineStyle(
        "background-color",
        active ? "transparent" : "#111",
        pre: qaTabCheckedSelector
      )
      .inlineStyle(
        "background-color",
        active ? "transparent" : "#fff",
        media: .dark,
        pre: qaTabCheckedSelector
      )
      .inlineStyle("border", "1px solid #111")
      .inlineStyle("border", "1px solid #fff", media: .dark)
      .inlineStyle("border-radius", "999px")
      .inlineStyle("color", active ? "#fff" : "#111")
      .inlineStyle("color", active ? "#111" : "#fff", media: .dark)
      .inlineStyle("color", active ? "#111" : "#fff", pre: qaTabCheckedSelector)
      .inlineStyle(
        "color",
        active ? "#fff" : "#111",
        media: .dark,
        pre: qaTabCheckedSelector
      )
      .inlineStyle("cursor", "pointer")
      .inlineStyle("font-size", "0.875rem")
      .inlineStyle("font-weight", "500")
      .inlineStyle("padding", "0.5rem 0.875rem")
  }
}

// MARK: - Past office hours

private struct PastOfficeHoursList: HTML {
  let pastOfficeHours: [Models.OfficeHour]
  let answeredQuestions: [Models.OfficeHour.ID: [Models.OfficeHourQuestion]]

  var body: some HTML {
    if pastOfficeHours.isEmpty {
      Paragraph {
        "No past office hours yet. The archive will grow after our first session!"
      }
      .color(.gray400.dark(.gray650))
      .inlineStyle("text-align", "center")
    } else {
      VStack(spacing: 3) {
        HTMLForEach(pastOfficeHours) { officeHour in
          PastOfficeHourRow(
            officeHour: officeHour,
            questions: answeredQuestions[officeHour.id] ?? []
          )
        }
      }
      .inlineStyle("width", "100%")
    }
  }
}

private struct PastOfficeHourRow: HTML {
  let officeHour: Models.OfficeHour
  let questions: [Models.OfficeHourQuestion]

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

          if !questions.isEmpty {
            AnsweredQuestionsList(
              cloudflareVideoID: cloudflareVideoID,
              questions: questions.sorted {
                ($0.answeredAtSeconds ?? 0) < ($1.answeredAtSeconds ?? 0)
              }
            )
          }
        }
      }
    }
  }
}

private struct AnsweredQuestionsList: HTML {
  let cloudflareVideoID: Cloudflare.Video.ID
  let questions: [Models.OfficeHourQuestion]

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    VStack(spacing: 0.25) {
      Header(6) {
        "Questions answered in this session"
      }
      .color(.black.dark(.white))
      .inlineStyle("margin-top", "0.5rem")

      ul {
        HTMLForEach(questions) { question in
          li {
            a {
              if let seconds = question.answeredAtSeconds {
                HTMLText("\(timestampLabel(seconds: seconds)) — ")
              }
              HTMLText(question.question)
            }
            .href(detailPath(question: question))
            .inlineStyle("color", "inherit")
            .inlineStyle("text-decoration", "none")
            .inlineStyle("text-decoration", "underline", pseudo: .hover)
          }
        }
      }
      .color(.gray400.dark(.gray650))
      .fontStyle(.body(.small))
      .inlineStyle("margin", "0")
      .inlineStyle("padding-left", "1.25rem")
    }
  }

  func detailPath(question: Models.OfficeHourQuestion) -> String {
    let path = siteRouter.path(
      for: .officeHours(.officeHour(cloudflareVideoID: cloudflareVideoID))
    )
    guard let seconds = question.answeredAtSeconds else { return path }
    return "\(path)#t\(seconds.rawValue)"
  }
}

// MARK: - Q&A

private struct QuestionsSection: HTML {
  let questions: [Models.OfficeHourQuestion]

  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    VStack(spacing: 2) {
      if subscriberState.isMaxSubscriber {
        SubmitQuestionForm()
      } else {
        Paragraph(.small) {
          """
          Submitting and voting on questions is exclusive to Point-Free Max subscribers.
          """
        }
        .color(.gray400.dark(.gray650))
        .inlineStyle("text-align", "center")
      }

      if questions.isEmpty {
        Paragraph {
          "No questions have been submitted yet. Be the first to ask one!"
        }
        .color(.gray400.dark(.gray650))
        .inlineStyle("text-align", "center")
      } else {
        VStack(spacing: 1) {
          HTMLForEach(questions) { question in
            QuestionRow(question: question)
          }
        }
        .inlineStyle("width", "100%")
      }
    }
    .inlineStyle("margin", "0 auto")
    .inlineStyle("max-width", "768px")
    .inlineStyle("width", "100%")
  }
}

private struct SubmitQuestionForm: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    form {
      VStack(spacing: 0.75) {
        textarea { "" }
          .attribute("name", "question")
          .attribute("rows", "3")
          .attribute(
            "placeholder",
            "What would you like us to cover in the next office hours?"
          )
          .inlineStyle("background-color", "#fff")
          .inlineStyle("background-color", "#1a1a1a", media: .dark)
          .inlineStyle("border", "1px solid rgba(15, 18, 32, 0.2)")
          .inlineStyle("border-color", "rgba(255, 255, 255, 0.2)", media: .dark)
          .inlineStyle("border-radius", "0.5rem")
          .inlineStyle("box-sizing", "border-box")
          .inlineStyle("color", "#111")
          .inlineStyle("color", "#fff", media: .dark)
          .inlineStyle("font-family", "inherit")
          .inlineStyle("font-size", "1rem")
          .inlineStyle("padding", "0.75rem")
          .inlineStyle("resize", "vertical")
          .inlineStyle("width", "100%")

        VStack {
          Button(tag: button, color: .purple, size: .regular) {
            "Submit question"
          }
          .attribute("type", "submit")
          .inlineStyle("align-self", "flex-start")

          span {
            "Questions are anonymous: your name is never shown."
          }
          .fontStyle(.body(.small))
          .color(.gray400.dark(.gray650))
        }
      }
    }
    .attribute(
      "action",
      siteRouter.path(for: .officeHours(.submitQuestion(question: "")))
    )
    .attribute("method", "post")
  }
}

private struct QuestionRow: HTML {
  let question: Models.OfficeHourQuestion

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var isOwnQuestion: Bool {
    currentUser?.id == question.userID
  }

  var body: some HTML {
    HStack(alignment: .center, spacing: 1) {
      VoteControl(question: question, isOwnQuestion: isOwnQuestion)

      VStack(spacing: 0.25) {
        HTMLMarkdown(question.question)
          .color(.black.dark(.white))
          .linkColor(.purple)

        span {
          HTMLText("Asked \(headerDateFormatter.string(from: question.createdAt))")
          if isOwnQuestion {
            " • Your question"
          } else if question.hasVoted {
            " • You voted for this"
          }
        }
        .fontStyle(.body(.small))
        .color(.gray400.dark(.gray650))
      }
      .grow()

      if isOwnQuestion {
        form {
          button {
            "Delete"
          }
          .attribute("type", "submit")
          .attribute("title", "Delete this question")
          .color(.gray400.dark(.gray650))
          .inlineStyle("background", "none")
          .inlineStyle("border", "none")
          .inlineStyle("color", PointFreeColor.red.rawValue, pseudo: .hover)
          .inlineStyle("cursor", "pointer")
          .inlineStyle("font-family", "inherit")
          .inlineStyle("font-size", "0.875rem")
          .inlineStyle("padding", "0")
          .inlineStyle("text-decoration", "underline", pseudo: .hover)
        }
        .attribute(
          "action",
          siteRouter.path(for: .officeHours(.deleteQuestion(id: question.id)))
        )
        .attribute("method", "post")
        .attribute("onsubmit", "return confirm(\"Delete this question?\")")
      }
    }
    .inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
    .inlineStyle("border-color", "rgba(255, 255, 255, 0.12)", media: .dark)
    .inlineStyle("border-radius", "0.75rem")
    .inlineStyle("padding", "1rem")
    .inlineStyle("width", "100%")
    .inlineStyle("box-sizing", "border-box")
  }
}

private struct VoteControl: HTML {
  let question: Models.OfficeHourQuestion
  let isOwnQuestion: Bool

  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var canVote: Bool {
    currentUser != nil
      && subscriberState.isMaxSubscriber
      && !isOwnQuestion
      && !question.hasVoted
  }

  var body: some HTML {
    if canVote {
      form {
        Button(tag: button, color: .purple, size: .small, style: .outline) {
          HTMLText("▲ \(question.voteCount)")
        }
        .attribute("type", "submit")
      }
      .attribute(
        "action",
        siteRouter.path(for: .officeHours(.voteQuestion(id: question.id)))
      )
      .attribute("method", "post")
    } else {
      span {
        HTMLText("▲ \(question.voteCount)")
      }
      .fontStyle(.body(.small))
      .color(question.hasVoted ? .purple : .gray400.dark(.gray650))
      .inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
      .inlineStyle("border-color", "rgba(255, 255, 255, 0.12)", media: .dark)
      .inlineStyle("border-radius", "999px")
      .inlineStyle("padding", "0.25rem 0.75rem")
      .inlineStyle("white-space", "nowrap")
    }
  }
}

// MARK: - Shared components

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

private func timestampLabel(seconds: Seconds<Int>) -> String {
  let total = seconds.rawValue
  let hours = total / 3600
  let minutes = (total % 3600) / 60
  let secs = total % 60
  return hours > 0
    ? String(format: "%d:%02d:%02d", hours, minutes, secs)
    : String(format: "%d:%02d", minutes, secs)
}

private let officeHoursScheduledAtFormatter: DateFormatter = {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .short
  return df
}()
