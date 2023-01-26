import URLRouting
import VimeoClient

public enum ClipsRoute: Equatable {
  case clip(videoID: VimeoVideo.ID)
}

let clipsRouter = OneOf {
  Route(.case(ClipsRoute.clip(videoID:))) {
    Path {
      Digits().map(.representing(VimeoVideo.ID.self))
    }
  }
}
