import EmailAddress
import Models
import URLRouting

// TODO: rename to Team
public enum Join: Equatable {
  case confirm(code: Subscription.TeamInviteCode, secret: Encrypted<String>)
  case join(code: Subscription.TeamInviteCode, email: EmailAddress?)
  case landing(code: Subscription.TeamInviteCode)
}

struct JoinRouter: ParserPrinter {
  var body: some Router<Join> {
    OneOf {
      Route(.case(Join.confirm)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
          "confirm"
          Parse(.string.representing(Encrypted.self))
        }
      }

      Route(.case(Join.join)) {
        Method.post
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
        }
        Optionally {
          Body {
            FormData {
              Field("email", .string.representing(EmailAddress.self))
            }
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
