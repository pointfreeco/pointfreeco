import CasePaths
import EmailAddress
import Models
import URLRouting

@CasePathable
public enum TeamInviteCode: Equatable {
  case confirm(code: Subscription.TeamInviteCode, secret: Encrypted<String>)
  case join(code: Subscription.TeamInviteCode, email: EmailAddress?)
  case landing(code: Subscription.TeamInviteCode)
}

struct JoinRouter: ParserPrinter {
  var body: some Router<TeamInviteCode> {
    OneOf(output: TeamInviteCode.self) {
      Route(.case(\.confirm)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
          "confirm"
          Parse(.string.representing(Encrypted.self))
        }
      }

      Route(.case(\.join)) {
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

      Route(.case(\.landing)) {
        Path {
          Parse(.string.representing(Subscription.TeamInviteCode.self))
        }
      }
    }
  }
}
