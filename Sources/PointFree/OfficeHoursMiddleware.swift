import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeDependencies
import PointFreeRouter
import Prelude
import StyleguideV2
import Views

func officeHoursMiddleware(
  _ conn: Conn<StatusLineOpen, OfficeHoursRoute>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database

  guard currentUser.hasAccess(to: .officeHours) else {
    return routeNotFoundMiddleware(conn)
  }

  do {
    switch conn.data {
    case let .deleteQuestion(id):
      return await deleteQuestionMiddleware(questionID: id, conn: conn.map(const(())))

    case let .officeHour(cloudflareVideoID: cloudflareVideoID):
      let officeHour = try await database.fetchOfficeHour(cloudflareVideoID: cloudflareVideoID)
      return await officeHourMiddleware(officeHour: officeHour, conn: conn.map(const(())))

    case let .index(tab):
      return await officeHoursIndexMiddleware(tab: tab, conn: conn.map(const(())))

    case let .submitQuestion(question):
      return await submitQuestionMiddleware(question: question, conn: conn.map(const(())))

    case let .voteQuestion(id):
      return await voteQuestionMiddleware(questionID: id, conn: conn.map(const(())))
    }
  } catch {
    return routeNotFoundMiddleware(conn)
  }
}

private func officeHourMiddleware(
  officeHour: OfficeHour,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database

  let questions = ((try? await database.fetchOfficeHourQuestions(
    answered: true,
    userID: currentUser?.id
  )) ?? [])
    .filter { $0.answeredOfficeHourID == officeHour.id }
    .sorted { ($0.answeredAtSeconds ?? 0) < ($1.answeredAtSeconds ?? 0) }

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: officeHour.blurb,
        image: officeHour.posterURL,
        title: officeHour.title,
        usePrismJs: true
      )
    ) {
      OfficeHourDetail(officeHour: officeHour, questions: questions)
    }
}

private func officeHoursIndexMiddleware(
  tab: OfficeHoursRoute.Tab,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  do {
    let officeHours = try await database.fetchOfficeHours()
    let unansweredQuestions = try await database.fetchOfficeHourQuestions(
      answered: false,
      userID: currentUser?.id
    )
    let answeredQuestions = try await database.fetchOfficeHourQuestions(
      answered: true,
      userID: currentUser?.id
    )

    return
      conn
      .writeStatus(.ok)
      .respondV2(
        layoutData: SimplePageLayoutData(
          description: """
            Periodic livestreams exclusively for Point-Free Max subscribers.
            """,
          title: "Point-Free Office Hours",
          usePrismJs: true
        )
      ) {
        OfficeHoursIndex(
          officeHours: officeHours,
          selectedTab: tab,
          unansweredQuestions: unansweredQuestions,
          answeredQuestions: Dictionary(
            grouping: answeredQuestions.filter { $0.answeredOfficeHourID != nil },
            by: { $0.answeredOfficeHourID! }
          )
        )
      }
  } catch {
    return routeNotFoundMiddleware(conn)
  }
}

private func submitQuestionMiddleware(
  question: String,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.subscriberState) var subscriberState

  guard let currentUser else {
    return conn.loginAndRedirect()
  }
  guard subscriberState.isMaxSubscriber else {
    return conn.redirect(to: .officeHours(.index(tab: .qa))) {
      $0.flash(.error, "You must be a Point-Free Max subscriber to submit questions.")
    }
  }
  let question = question.trimmingCharacters(in: .whitespacesAndNewlines)
  guard !question.isEmpty else {
    return conn.redirect(to: .officeHours(.index(tab: .qa))) {
      $0.flash(.error, "Please enter a question.")
    }
  }

  do {
    _ = try await database.submitOfficeHourQuestion(
      question: question,
      userID: currentUser.id
    )
    return conn.redirect(to: .officeHours(.index(tab: .qa))) {
      $0.flash(.notice, "Your question has been submitted!")
    }
  } catch {
    return conn.redirect(to: .officeHours(.index(tab: .qa))) {
      $0.flash(.error, "Something went wrong. Please try again.")
    }
  }
}

private func deleteQuestionMiddleware(
  questionID: OfficeHourQuestion.ID,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database

  guard let currentUser else {
    return conn.writeStatus(.unauthorized).respondFragment { HTMLEmpty() }
  }

  do {
    try await database.deleteOfficeHourQuestion(id: questionID, userID: currentUser.id)
    return try await questionsFragmentResponse(conn, userID: currentUser.id)
  } catch {
    return conn.writeStatus(.internalServerError).respondFragment { HTMLEmpty() }
  }
}

private func voteQuestionMiddleware(
  questionID: OfficeHourQuestion.ID,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.database) var database
  @Dependency(\.subscriberState) var subscriberState

  guard
    let currentUser,
    subscriberState.isMaxSubscriber
  else {
    return conn.writeStatus(.unauthorized).respondFragment { HTMLEmpty() }
  }

  do {
    try await database.voteOfficeHourQuestion(questionID: questionID, userID: currentUser.id)
    return try await questionsFragmentResponse(conn, userID: currentUser.id)
  } catch {
    return conn.writeStatus(.internalServerError).respondFragment { HTMLEmpty() }
  }
}

private func questionsFragmentResponse(
  _ conn: Conn<StatusLineOpen, Void>,
  userID: Models.User.ID
) async throws -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database

  let questions = try await database.fetchOfficeHourQuestions(
    answered: false,
    userID: userID
  )
  return conn.writeStatus(.ok).respondFragment(
    scope: "#\(OfficeHourQuestionsList.elementID)"
  ) {
    OfficeHourQuestionsList(questions: questions)
  }
}
