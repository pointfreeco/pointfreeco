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
      Periodic livestreams exclusively for Point-Free Max members. Bring us your \
      questions about our episodes and libraries and we will discuss them live on the air.
      """
    }

    if let liveOfficeHour {
      if subscriberState.canWatch(liveOfficeHour), !liveOfficeHour.youtubeVideoID.isEmpty {
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
        notice: """
          Scheduled for \(officeHoursScheduledAtFormatter.string(from: scheduledAt)) GMT
          """,
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
  let questions: [Models.OfficeHourQuestion]

  @Dependency(\.subscriberState) var subscriberState

  public init(officeHour: Models.OfficeHour, questions: [Models.OfficeHourQuestion] = []) {
    self.officeHour = officeHour
    self.questions = questions
  }

  var subtitle: String {
    let access =
      switch officeHour.access {
      case .free: "Free for everyone"
      case .pro: "Members only"
      case .max: "Max members only"
      }
    return """
      Office Hours • \
      \(headerDateFormatter.string(from: officeHour.scheduledAt ?? officeHour.createdAt)) • \
      \(access)
      """
  }

  var canWatch: Bool {
    subscriberState.canWatch(officeHour)
  }

  public var body: some HTML {
    if let cloudflareVideoID = officeHour.cloudflareVideoID {
      if canWatch {
        VideoHeader(
          title: officeHour.title,
          subtitle: subtitle,
          blurb: officeHour.description,
          videoID: cloudflareVideoID,
          poster: officeHour.posterURL,
          progress: nil,
          trackProgress: false
        )
        if officeHour.access != .max, !subscriberState.isMaxSubscriber {
          SneakPeekCallout(access: officeHour.access)
        }
      } else {
        LockedOfficeHourHeader(officeHour: officeHour, subtitle: subtitle)
        switch officeHour.access {
        case .free, .pro:
          ProSubscriberCallout()
        case .max:
          MaxSubscriberCallout()
        }
      }

      if !questions.isEmpty {
        AnsweredQuestionsModule(
          questions: questions,
          isViewable: canWatch
        )
      }

      if let transcript = officeHour.transcript, !transcript.isEmpty {
        OfficeHourTranscriptModule(
          transcript: transcript,
          questions: questions,
          isViewable: canWatch
        )
      }
    }
  }
}

private struct LockedOfficeHourHeader: HTML {
  let officeHour: Models.OfficeHour
  let subtitle: String

  var body: some HTML {
    CenterColumn {
      VStack(alignment: .center, spacing: 0) {
        Header(3) {
          HTMLText(officeHour.title)
        }
        .color(.offWhite)
        .inlineStyle("text-align", "center")
        .inlineStyle("text-wrap", "balance")

        span {
          HTMLText(subtitle)
        }
        .color(.gray800)

        HTMLMarkdown(trusted: officeHour.description)
          .color(.gray900)
          .linkStyle(.init(color: .offWhite, underline: true))
          .inlineStyle("max-width", "768px")
          .inlineStyle("margin-top", "2rem")
          .inlineStyle("text-align", "justify")
      }
      .inlineStyle("padding", "3rem 2rem 6rem")
      .inlineStyle("padding", "4rem 3rem 6rem", media: .desktop)
    }
    .inlineStyle("background", "linear-gradient(#121212, #242424)")
    .inlineStyle("padding-bottom", "2rem")

    CenterColumn {
      div {
        div {
          Image(source: officeHour.posterURL, description: "")
            .inlineStyle("display", "block")
            .inlineStyle("filter", "brightness(0.35)")
            .inlineStyle("height", "100%")
            .inlineStyle("object-fit", "cover")
            .inlineStyle("position", "absolute")
            .inlineStyle("width", "100%")

          div {
            VStack(alignment: .center, spacing: 1) {
              span { "🔒" }
                .inlineStyle("font-size", "2rem")

              Header(4) {
                switch officeHour.access {
                case .free:
                  "This video is free for everyone"
                case .pro:
                  "This video is for Point-Free members"
                case .max:
                  "This video is for Max members"
                }
              }
              .color(.white)
              .inlineStyle("text-align", "center")
            }
          }
          .inlineStyle("align-items", "center")
          .inlineStyle("display", "flex")
          .inlineStyle("inset", "0")
          .inlineStyle("justify-content", "center")
          .inlineStyle("padding", "2rem")
          .inlineStyle("position", "absolute")
        }
        .inlineStyle("aspect-ratio", "16 / 9")
        .inlineStyle("background", "#000")
        .inlineStyle("box-shadow", "0rem 1rem 20px rgba(0,0,0,0.2)")
        .inlineStyle("overflow", "hidden")
        .inlineStyle("position", "relative")
      }
      .inlineStyle("box-sizing", "border-box")
      .inlineStyle("padding", "0 4rem", media: .desktop)
    }
    .inlineStyle("margin-top", "-4rem")
    .inlineStyle("padding-bottom", "4rem")
  }
}

private struct AnsweredQuestionsModule: HTML {
  let questions: [Models.OfficeHourQuestion]
  let isViewable: Bool

  var body: some HTML {
    PageModule(title: "Questions answered in this session", theme: .content) {
      VStack(spacing: 1) {
        HTMLForEach(questions) { question in
          HStack(alignment: .firstTextBaseline, spacing: 1) {
            if let seconds = question.answeredAtSeconds {
              if isViewable {
                a {
                  HTMLText(timestampLabel(seconds: seconds))
                }
                .attribute("href", "#t\(seconds.rawValue)")
                .attribute("data-timestamp", "\(seconds.rawValue)")
                .inlineStyle("color", "#974dff")
                .inlineStyle("font-variant-numeric", "tabular-nums")
                .inlineStyle("text-decoration", "none")
                .inlineStyle("text-decoration", "underline", pseudo: .hover)
              } else {
                span {
                  HTMLText(timestampLabel(seconds: seconds))
                }
                .color(.gray400.dark(.gray650))
                .inlineStyle("font-variant-numeric", "tabular-nums")
              }
            }

            HTMLMarkdown(untrusted: question.question)
              .color(.gray150.dark(.gray850))
              .linkColor(.purple)
              .grow()
          }
          .inlineStyle("width", "100%")
        }
      }
      .inlineStyle("margin", "0 auto")
      .inlineStyle("max-width", "768px")
      .inlineStyle("width", "100%")
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
              title: "Upcoming Questions",
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
            switch officeHour.access {
            case .free:
              " • Free for everyone"
            case .pro:
              " • Free for members"
            case .max:
              HTMLEmpty()
            }
          }
          .fontStyle(.body(.small))
          .color(.gray400.dark(.gray650))

          if !officeHour.blurb.isEmpty {
            HTMLMarkdown(trusted: officeHour.blurb)
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
          let questionText = HTMLMarkdown.plainText(question.question, limit: 280)
          li {
            a {
              if let seconds = question.answeredAtSeconds {
                HTMLText("\(timestampLabel(seconds: seconds)) — ")
              }
              HTMLText(questionText)
            }
            .href(detailPath(question: question))
            .attribute("title", questionText)
            .inlineStyle("color", "inherit")
            .inlineStyle("display", "block")
            .inlineStyle("max-width", "100%")
            .inlineStyle("overflow", "hidden")
            .inlineStyle("text-decoration", "none")
            .inlineStyle("text-decoration", "underline", pseudo: .hover)
            .inlineStyle("text-overflow", "ellipsis")
            .inlineStyle("white-space", "nowrap")
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
            Submitting and voting on questions is exclusive to Point-Free Max members.
            """
        }
        .color(.gray400.dark(.gray650))
        .inlineStyle("text-align", "center")
      }

      OfficeHourQuestionsList(questions: questions)
      QuestionsScript()
    }
    .inlineStyle("margin", "0 auto")
    .inlineStyle("max-width", "768px")
    .inlineStyle("width", "100%")
  }
}

public struct OfficeHourQuestionsList: HTML {
  fileprivate static let elementID = "office-hours-questions"

  let questions: [Models.OfficeHourQuestion]

  public init(questions: [Models.OfficeHourQuestion]) {
    self.questions = questions
  }

  public var body: some HTML {
    VStack(spacing: 1) {
      if questions.isEmpty {
        Paragraph {
          "No questions have been submitted yet. Be the first to ask one!"
        }
        .color(.gray400.dark(.gray650))
        .inlineStyle("text-align", "center")
      } else {
        HTMLForEach(questions) { question in
          QuestionRow(question: question)
        }
      }
    }
    .attribute("id", Self.elementID)
    .inlineStyle("width", "100%")
  }
}

private struct QuestionsScript: HTML {
  var body: some HTML {
    script {
      #"""
      document.addEventListener("submit", async (event) => {
        const form = event.target;
        if (!form.hasAttribute("data-questions-form")) { 
          return; 
        }
        if (event.defaultPrevented) { 
          return; 
        }
        event.preventDefault();
        try {
          const response = await fetch(form.action, { method: "POST" });
          if (!response.ok) { 
            throw new Error(response.status); 
          }
          const list = document.getElementById("\#(OfficeHourQuestionsList.elementID)");
          if (!list) { 
            throw new Error("missing questions element"); 
          }
          list.innerHTML = await response.text();
          if (window.Prism) {
            Prism.highlightAllUnder(list);
          }
        } catch (error) {
          location.reload();
        }
      });
      """#
    }
  }
}

private struct SubmitQuestionForm: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    form {
      VStack(spacing: 0.75) {
        textarea { "" }
          .attribute("name", "question")
          .attribute("maxlength", "5000")
          .attribute("rows", "3")
          .attribute(
            "placeholder",
            "What would you like us to cover in the next office hours? Markdown is supported."
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
    guard let currentUser, let userID = question.userID else { return false }
    return currentUser.id == userID
  }

  var body: some HTML {
    HStack(alignment: .top, spacing: 1) {
      VoteControl(question: question, isOwnQuestion: isOwnQuestion)
      questionContent
      if isOwnQuestion {
        DeleteQuestionButton(questionID: question.id)
      }
    }
    .questionCard(isOwnQuestion: isOwnQuestion)
  }

  var questionContent: some HTML {
    VStack(spacing: 0.25) {
      ExpandableQuestionMarkdown(question: question)

      span {
        HTMLText("Asked \(headerDateFormatter.string(from: question.createdAt))")
        if isOwnQuestion {
          " • "
          strong { "Your question" }
        } else if question.hasVoted {
          " • You voted for this"
        }
      }
      .fontStyle(.body(.small))
      .color(.gray400.dark(.gray650))
    }
    .grow()
  }
}

private struct ExpandableQuestionMarkdown: HTML {
  let question: Models.OfficeHourQuestion

  var isLong: Bool {
    question.question.count > 800
      || question.question.count(where: { $0 == "\n" }) >= 10
  }

  var expandID: String {
    "expand-question-\(question.id.rawValue.uuidString.lowercased())"
  }

  var body: some HTML {
    if isLong {
      input()
        .attribute("id", expandID)
        .attribute("type", "checkbox")
        .inlineStyle("display", "none")

      HTMLMarkdown(untrusted: question.question)
        .color(.black.dark(.white))
        .linkColor(.purple)
        .inlineStyle("max-height", "15em")
        .inlineStyle(
          "mask-image",
          "linear-gradient(to bottom, black 66%, transparent 100%)"
        )
        .inlineStyle("overflow", "hidden")
        .inlineStyle("mask-image", "none", pre: "input:checked ~")
        .inlineStyle("max-height", "none", pre: "input:checked ~")
        .inlineStyle("overflow", "visible", pre: "input:checked ~")

      label {
        "Show more"
      }
      .attribute("for", expandID)
      .fontStyle(.body(.small))
      .inlineStyle("color", "#974dff")
      .inlineStyle("cursor", "pointer")
      .inlineStyle("display", "inline-block")
      .inlineStyle("display", "none", pre: "input:checked ~")
      .inlineStyle("text-decoration", "underline", pseudo: .hover)
    } else {
      HTMLMarkdown(untrusted: question.question)
        .color(.black.dark(.white))
        .linkColor(.purple)
    }
  }
}

private struct DeleteQuestionButton: HTML {
  let questionID: Models.OfficeHourQuestion.ID

  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
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
      siteRouter.path(for: .officeHours(.deleteQuestion(id: questionID)))
    )
    .attribute("method", "post")
    .attribute("data-questions-form", "")
    .attribute("onsubmit", "return confirm(\"Delete this question?\")")
  }
}

extension HTML {
  fileprivate func questionCard(isOwnQuestion: Bool) -> some HTML {
    self
      .inlineStyle("background-color", isOwnQuestion ? "rgba(15, 18, 32, 0.04)" : nil)
      .inlineStyle(
        "background-color",
        isOwnQuestion ? "rgba(255, 255, 255, 0.06)" : nil,
        media: .dark
      )
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
        button {
          VotePillContent(voteCount: question.voteCount)
        }
        .attribute("type", "submit")
        .attribute("title", "Vote for this question")
        .votePill()
        .inlineStyle("color", "inherit")
        .inlineStyle("cursor", "pointer")
        .inlineStyle("background-color", "transparent")
        .inlineStyle("border-color", "#974dff", pseudo: .hover)
        .inlineStyle("color", "#974dff", pseudo: .hover)
        .inlineStyle(
          "background-color",
          "color-mix(in oklab, #974dff 8%, transparent)",
          pseudo: .hover
        )
      }
      .color(.gray400.dark(.gray650))
      .attribute(
        "action",
        siteRouter.path(for: .officeHours(.voteQuestion(id: question.id)))
      )
      .attribute("method", "post")
      .attribute("data-questions-form", "")
    } else if question.hasVoted {
      span {
        VotePillContent(voteCount: question.voteCount)
      }
      .attribute("title", "You voted for this question")
      .votePill()
      .color(.purple)
      .inlineStyle("border-color", "color-mix(in oklab, #974dff 40%, transparent)")
      .inlineStyle("background-color", "color-mix(in oklab, #974dff 10%, transparent)")
    } else {
      span {
        VotePillContent(voteCount: question.voteCount)
      }
      .votePill()
      .color(.gray400.dark(.gray650))
      .inlineStyle("background-color", "transparent")
    }
  }
}

private struct VotePillContent: HTML {
  let voteCount: Int

  var body: some HTML {
    span { "▲" }
      .inlineStyle("font-size", "0.7rem")
      .inlineStyle("line-height", "1")
    span { HTMLText("\(voteCount)") }
      .inlineStyle("font-size", "0.875rem")
      .inlineStyle("font-weight", "600")
      .inlineStyle("line-height", "1.2")
  }
}

extension HTML {
  fileprivate func votePill() -> some HTML {
    self
      .inlineStyle("align-items", "center")
      .inlineStyle("border", "1px solid rgba(15, 18, 32, 0.15)")
      .inlineStyle("border-color", "rgba(255, 255, 255, 0.15)", media: .dark)
      .inlineStyle("border-radius", "0.5rem")
      .inlineStyle("display", "flex")
      .inlineStyle("flex-direction", "column")
      .inlineStyle("font-family", "inherit")
      .inlineStyle("gap", "0.2rem")
      .inlineStyle("min-width", "2.25rem")
      .inlineStyle("padding", "0.5rem 0.5rem")
      .inlineStyle("transition", "color 150ms ease, border-color 150ms ease")
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
            HTMLMarkdown(trusted: description)
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

private struct SneakPeekCallout: HTML {
  let access: Models.OfficeHour.Access

  @Dependency(\.currentRoute) var currentRoute
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CenterColumn {
      VStack {
        div {
          HStack(spacing: 0.5) {
            SVG(base64: unlockSvgBase64, description: "Free")
            switch access {
            case .free:
              "This session is free for everyone."
            case .pro:
              "This session is free for all Point-Free members."
            case .max:
              HTMLEmpty()
            }
          }
          .inlineStyle("justify-content", "center")
        }
        .backgroundColor(.gray900.dark(.gray150))
        .fontStyle(.body(.small))
        .inlineStyle("border-bottom", "1px solid #ccc")
        .inlineStyle("border-bottom", "1px solid #555", media: .dark)
        .inlineStyle("font-weight", "600")
        .inlineStyle("line-height", "3")

        VStack(spacing: 0.5) {
          Header(4) {
            "Get Point-Free Max"
          }
          .color(.offBlack.dark(.offWhite))

          Paragraph {
            """
            Catch every office hours session live, watch the full archive, and submit and \
            vote on the questions we answer, when you become a Max member.
            """
          }
          .inlineStyle("margin-bottom", "1rem")
          .inlineStyle("text-wrap", "balance")

          VStack(alignment: .center, spacing: 0.5) {
            Button(color: .purple) {
              "See plans and pricing"
            }
            .attribute("href", siteRouter.path(for: .pricingLanding))

            if currentUser == nil {
              span {
                "Already a member? "
                Link("Log in", href: siteRouter.loginPath(redirect: currentRoute))
              }
            }
          }
          .fontStyle(.body(.small))
        }
        .inlineStyle("padding", "1rem 2rem 2rem")
      }
      .linkColor(.purple)
      .color(.gray650.dark(.gray500))
      .inlineStyle("border", "1px solid #ccc")
      .inlineStyle("border", "1px solid #555", media: .dark)
      .inlineStyle("border-radius", "6px")
      .inlineStyle("margin", "0 auto 3rem")
      .inlineStyle("max-width", "768px")
      .inlineStyle("overflow", "hidden")
      .inlineStyle("text-align", "center")
    }
  }
}

private struct ProSubscriberCallout: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    CalloutModule(
      title: "Free for Point-Free members",
      subtitle: """
        This office hours session is available to all Point-Free members. Join today to \
        watch it, plus get access to all of our videos.
        """,
      ctaTitle: "See plans and pricing",
      ctaURL: siteRouter.path(for: .pricingLanding)
    )
  }
}

private struct MaxSubscriberCallout: HTML {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    CalloutModule(
      title: "Exclusively for Max members",
      subtitle: """
        Join our live office hours and watch the full archive of past sessions by becoming a \
        Point-Free Max member.
        """,
      ctaTitle: "Become a Max member",
      ctaURL: siteRouter.path(for: subscriberState.subscribeToMaxRoute)
    )
  }
}

private struct OfficeHoursLiveEmbeds: HTML {
  let officeHour: Models.OfficeHour

  @Dependency(\.envVars.baseUrl) var baseURL

  var body: some HTML {
    div {
      LazyVGrid(
        columns: [.mobile: [1], .desktop: [2, 1]],
        alignItems: .start,
        horizontalSpacing: 0,
        verticalSpacing: 0
      ) {
        OfficeHoursVideoEmbed(youtubeVideoID: officeHour.youtubeVideoID)
        OfficeHoursChatEmbed(
          youtubeVideoID: officeHour.youtubeVideoID,
          host: baseURL.host() ?? "localhost"
        )
      }
      .inlineStyle("width", "100%")
    }
    .backgroundColor(.black)
    .inlineStyle("padding", "0")
  }
}

private struct OfficeHoursVideoEmbed: HTML {
  let youtubeVideoID: String

  var body: some HTML {
    div {
      iframe()
        .attribute(
          "src",
          "https://www.youtube.com/embed/\(youtubeVideoID)"
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
  let youtubeVideoID: String
  let host: String

  var body: some HTML {
    div {
      iframe()
        .attribute(
          "src",
          "https://www.youtube.com/live_chat?v=\(youtubeVideoID)&embed_domain=\(host)"
        )
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
    .inlineStyle("display", "none", media: .mobile)
  }
}

func timestampLabel(seconds: Seconds<Int>) -> String {
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
  df.timeZone = TimeZone(identifier: "GMT")
  return df
}()
