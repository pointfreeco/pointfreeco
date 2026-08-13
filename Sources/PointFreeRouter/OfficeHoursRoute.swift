import Cloudflare
import Foundation
import Models
import URLRouting

public enum OfficeHoursRoute: Equatable {
  case deleteQuestion(id: OfficeHourQuestion.ID)
  case index(tab: Tab = .pastOfficeHours)
  case officeHour(cloudflareVideoID: Cloudflare.Video.ID)
  case submitQuestion(question: String)
  case voteQuestion(id: OfficeHourQuestion.ID)

  public enum Tab: Equatable {
    case pastOfficeHours
    case qa
  }
}

struct OfficeHoursRouter: ParserPrinter {
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
      Route(.case(OfficeHoursRoute.voteQuestion(id:))) {
        Method.post
        Path {
          "questions"
          UUID.parser().map(.representing(OfficeHourQuestion.ID.self))
          "vote"
        }
      }
      Route(.case(OfficeHoursRoute.deleteQuestion(id:))) {
        Method.post
        Path {
          "questions"
          UUID.parser().map(.representing(OfficeHourQuestion.ID.self))
          "delete"
        }
      }
      Route(.case(OfficeHoursRoute.index(tab:))) {
        OneOf {
          Route(.case(OfficeHoursRoute.Tab.pastOfficeHours))
          Route(.case(OfficeHoursRoute.Tab.qa)) {
            Path { "qa" }
          }
        }
      }
      Route(.case(OfficeHoursRoute.officeHour(cloudflareVideoID:))) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
    }
  }
}
