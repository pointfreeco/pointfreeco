import Cloudflare
import IssueReporting
import Models
import URLRouting
import Vimeo

public enum ClipsRoute: Equatable {
  case cloudflareClip(videoID: Cloudflare.Video.ID)
  case vimeoClip(videoID: Vimeo.Video.ID)
  case clips

  public static func clip(_ clip: Clip) -> Self {
    if let cloudflareVideoID = clip.cloudflareVideoID {
      return .cloudflareClip(videoID: cloudflareVideoID)
    } else if let vimeoVideoID = clip.vimeoVideoID {
      return .vimeoClip(videoID: vimeoVideoID)
    } else {
      reportIssue("Clip \(clip.id) has both 'vimeoVideoID' and 'cloudflareVideoID' nil.")
      return .clips
    }
  }
}

struct ClipsRouter: ParserPrinter {
  var body: some Router<ClipsRoute> {
    OneOf {
      Route(.case(ClipsRoute.cloudflareClip(videoID:))) {
        Path {
          Rest().map(.string.representing(Cloudflare.Video.ID.self))
        }
      }
      Route(.case(ClipsRoute.vimeoClip(videoID:))) {
        Path {
          Digits().map(.representing(Vimeo.Video.ID.self))
        }
      }
      Route(.case(ClipsRoute.clips))
    }
  }
}
