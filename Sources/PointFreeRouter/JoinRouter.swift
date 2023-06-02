import EmailAddress
import Models
import URLRouting

public enum Join: Equatable {
  case join(code: Subscription.TeamInviteCode, email: EmailAddress?)
  case landing(code: Subscription.TeamInviteCode)
}

struct JoinRouter: ParserPrinter {
  var body: some Router<Join> {
    OneOf {
      Route(.case(Join.join)) {
        Method.post
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
        }
        Query {
          Optionally {
            Field("email", .string.representing(EmailAddress.self))
          }
        }
      }

      Route(.case(Join.landing)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
        }
      }
    }
  }
}
