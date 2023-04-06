import URLRouting
import VimeoClient

public enum ClipsRoute: Equatable {
  case clip(videoID: VimeoVideo.ID)
}

struct ClipsRouter: ParserPrinter {
  var body: some Router<ClipsRoute> {
    OneOf {
      Route(.case(ClipsRoute.clip(videoID:))) {
        Path {
          Digits().map(.representing(VimeoVideo.ID.self))
        }
      }
    }
  }
}
