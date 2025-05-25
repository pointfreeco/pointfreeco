import Models
import URLRouting
import Vimeo

public enum Live: Equatable {
  case current
}

struct LiveRouter: ParserPrinter {
  var body: some Router<Live> {
    OneOf {
      Route(.case(Live.current))
    }
  }
}
