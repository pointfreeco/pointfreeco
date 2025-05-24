import Models
import URLRouting
import Vimeo

public enum Live: Equatable {
  case current
  case stream(id: Vimeo.Video.ID)
}

struct LiveRouter: ParserPrinter {
  var body: some Router<Live> {
    OneOf {
      Route(.case(Live.current))

      Route(.case(Live.stream(id:))) {
        Path {
          "streams"
          Digits().map(.representing(Vimeo.Video.ID.self))
        }
      }
    }
  }
}
