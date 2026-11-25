import CasePaths
import Cloudflare
import IssueReporting
import Models
import URLRouting

@CasePathable
public enum ClipsRoute: Equatable {
  case clip(cloudflareVideoID: Cloudflare.Video.ID)
  case clips
}

struct ClipsRouter: ParserPrinter {
  var body: some Router<ClipsRoute> {
    OneOf(output: ClipsRoute.self) {
      Route(.case(\.clip)) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
      Route(.case(\.clips))
    }
  }
}
