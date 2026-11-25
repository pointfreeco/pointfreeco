import CasePaths
import Cloudflare
import Foundation
import Models
import URLRouting

@CasePathable
public enum OfficeHoursRoute: Equatable {
  case deleteQuestion(id: OfficeHourQuestion.ID, questionsSort: QuestionsSort? = nil)
  case index(tab: Tab = .recordings, questionsSort: QuestionsSort? = nil)
  case officeHour(cloudflareVideoID: Cloudflare.Video.ID)
  case submitQuestion(question: String)
  case voteQuestion(id: OfficeHourQuestion.ID, questionsSort: QuestionsSort? = nil)

  @CasePathable
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
    OneOf(output: OfficeHoursRoute.self) {
      Route(.case(\.submitQuestion)) {
        Method.post
        Path { "questions" }
        Body {
          FormData {
            Field("question", default: "")
          }
        }
      }
      Route(.case(\.voteQuestion)) {
        Method.post
        Path {
          "questions"
          UUID.parser().map(.representing(OfficeHourQuestion.ID.self))
          "vote"
        }
        questionsSortQuery
      }
      Route(.case(\.deleteQuestion)) {
        Method.post
        Path {
          "questions"
          UUID.parser().map(.representing(OfficeHourQuestion.ID.self))
          "delete"
        }
        questionsSortQuery
      }
      Route(.case(\.index)) {
        OneOf(output: OfficeHoursRoute.Tab.self) {
          Route(.case(\.recordings))
          Route(.case(\.openQuestions)) {
            Path { "open-questions" }
          }
          Route(.case(\.answeredQuestions)) {
            Path { "answered-questions" }
          }
        }
        questionsSortQuery
      }
      Route(.case(\.officeHour)) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
    }
  }
}
