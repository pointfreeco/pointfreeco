import Cloudflare
import IssueReporting
import Models
import URLRouting

public enum ClipsRoute: Equatable {
  case clip(cloudflareVideoID: Cloudflare.Video.ID)
  case clips
}

struct ClipsRouter: ParserPrinter {
  var body: some Router<ClipsRoute> {
    OneOf {
      Route(.case(ClipsRoute.clip(cloudflareVideoID:))) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
      Route(.case(ClipsRoute.clips))
    }
  }
}
