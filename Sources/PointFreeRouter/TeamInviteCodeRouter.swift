import EmailAddress
import Models
import URLRouting

public enum TeamInviteCode: Equatable {
  case confirm(code: Subscription.TeamInviteCode, secret: Encrypted<String>)
  case join(code: Subscription.TeamInviteCode, email: EmailAddress?)
  case landing(code: Subscription.TeamInviteCode)
}

struct JoinRouter: ParserPrinter {
  var body: some Router<TeamInviteCode> {
    OneOf {
      Route(.case(TeamInviteCode.confirm)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
          "confirm"
          Parse(.string.representing(Encrypted.self))
        }
      }

      Route(.case(TeamInviteCode.join)) {
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

      Route(.case(TeamInviteCode.landing)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
        }
      }
    }
  }
}
