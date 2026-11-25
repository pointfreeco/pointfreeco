import CasePaths
import Models
import URLRouting

@CasePathable
public enum Live: Equatable {
  case current
}

struct LiveRouter: ParserPrinter {
  var body: some Router<Live> {
    OneOf(output: Live.self) {
      Route(.case(\.current))
    }
  }
}
