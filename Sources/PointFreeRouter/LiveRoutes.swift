import Models
import URLRouting

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
