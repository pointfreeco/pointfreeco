import Models
import URLRouting

public enum ClipsRoute: Equatable {
  case clip(videoID: VimeoVideo.ID)
  case clips
}

struct ClipsRouter: ParserPrinter {
  var body: some Router<ClipsRoute> {
    OneOf {
      Route(.case(ClipsRoute.clip(videoID:))) {
        Path {
          Digits().map(.representing(VimeoVideo.ID.self))
        }
      }
      Route(.case(ClipsRoute.clips))
    }
  }
}
