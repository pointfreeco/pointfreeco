import Either
import Prelude

public typealias AirtableCreateRow = (_ email: String) -> (_ baseId: String) -> EitherIO<Unit, Unit>

public struct Environment {
  public let airtableStuff: AirtableCreateRow

  init(airtableStuff: @escaping AirtableCreateRow = createRow) {
    self.airtableStuff = airtableStuff
  }
}

public struct AppEnvironment {
  private static var stack: [Environment] = [Environment()]
  public static var current: Environment { return stack.last! }

  public static func push(env: Environment) {
    self.stack.append(env)
  }

  public static func pop() {
    _ = self.stack.popLast()
  }
}
