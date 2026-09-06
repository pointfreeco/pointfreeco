import Cloudflare
import Foundation
import Models
import URLRouting

public enum OfficeHoursRoute: Equatable {
  case deleteQuestion(id: OfficeHourQuestion.ID, questionsSort: QuestionsSort? = nil)
  case index(tab: Tab = .recordings, questionsSort: QuestionsSort? = nil)
  case officeHour(cloudflareVideoID: Cloudflare.Video.ID)
  case submitQuestion(question: String)
  case voteQuestion(id: OfficeHourQuestion.ID, questionsSort: QuestionsSort? = nil)

  public enum Tab: CaseIterable, Equatable {
    case recordings
    case openQuestions
    case answeredQuestions
  }

  public enum QuestionsSort: String, CaseIterable, Equatable {
    case mostVotes = "most-votes"
    case mostRecent = "most-recent"
  }
}

struct OfficeHoursRouter: ParserPrinter {
  private var questionsSortQuery: some ParserPrinter<URLRequestData, OfficeHoursRoute.QuestionsSort?> {
    Query {
      Optionally {
        Field("sort") { OfficeHoursRoute.QuestionsSort.parser() }
      }
    }
  }

  var body: some Router<OfficeHoursRoute> {
    OneOf {
      Route(.case(OfficeHoursRoute.submitQuestion(question:))) {
        Method.post
        Path { "questions" }
        Body {
          FormData {
            Field("question", default: "")
          }
        }
      }
      Route(.case(OfficeHoursRoute.voteQuestion(id:questionsSort:))) {
        Method.post
        Path {
          "questions"
          UUID.parser().map(.representing(OfficeHourQuestion.ID.self))
          "vote"
        }
        questionsSortQuery
      }
      Route(.case(OfficeHoursRoute.deleteQuestion(id:questionsSort:))) {
        Method.post
        Path {
          "questions"
          UUID.parser().map(.representing(OfficeHourQuestion.ID.self))
          "delete"
        }
        questionsSortQuery
      }
      Route(.case(OfficeHoursRoute.index(tab:questionsSort:))) {
        OneOf {
          Route(.case(OfficeHoursRoute.Tab.recordings))
          Route(.case(OfficeHoursRoute.Tab.openQuestions)) {
            Path { "open-questions" }
          }
          Route(.case(OfficeHoursRoute.Tab.answeredQuestions)) {
            Path { "answered-questions" }
          }
        }
        questionsSortQuery
      }
      Route(.case(OfficeHoursRoute.officeHour(cloudflareVideoID:))) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
    }
  }
}
