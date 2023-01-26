import Models
import URLRouting
import VimeoClient

public enum Live: Equatable {
  case current
  case stream(id: VimeoVideo.ID)
}

let liveRouter = OneOf {
  Route(.case(Live.current))

  Route(.case(Live.stream(id:))) {
    Path {
      "stream"
      Digits().map(.representing(VimeoVideo.ID.self))
    }
  }
}
