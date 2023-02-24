import Models
import Tagged
import URLRouting
import VimeoClient

public enum Live: Equatable {
  case current
  case stream(id: VimeoVideo.ID)
}

struct LiveRouter: ParserPrinter {
  var body: some Router<Live> {
    OneOf {
      Route(.case(Live.current))

      Route(.case(Live.stream(id:))) {
        Path {
          "streams"
          Digits().map(.representing(VimeoVideo.ID.self))
        }
      }
    }
  }
}
