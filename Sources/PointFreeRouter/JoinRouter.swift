import Models
import URLRouting

public enum Join: Equatable {
  case code(Subscription.TeamInviteCode)
}

struct JoinRouter: ParserPrinter {
  var body: some Router<Join> {
    OneOf {
      Route(.case(Join.code)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
        }
      }
    }
  }
}
