import CasePaths
import Foundation
import GitHub
import Tagged
import URLRouting

@CasePathable
public enum GitHubRoute {
  case authorize(clientId: GitHub.Client.ID, redirectUri: String?, scope: String, state: UUID? = nil)
  case episodeCodeSample(directory: String)
  case license
  case organization
  case repo(Repo)

  public enum Repo: String, CaseIterable {
    case composableArchitecture = "swift-composable-architecture"
    case dependencies = "swift-dependencies"
    case html = "swift-html"
    case htmlKitura = "swift-html-kitura"
    case htmlVapor = "swift-html-vapor"
    case nonempty = "swift-nonempty"
    case overture = "swift-overture"
    case parsing = "swift-parsing"
    case pointfreeco
    case prelude = "swift-prelude"
    case snapshotTesting = "swift-snapshot-testing"
    case sqliteData = "sqlite-data"
    case tagged = "swift-tagged"
    case validated = "swift-validated"
    case web = "swift-web"
  }
}

public struct GitHubRouter: ParserPrinter {
  public init() {}

  public var body: some Router<GitHubRoute> {
    OneOf(output: GitHubRoute.self) {
      Route(.case(\.authorize)) {
        Path {
          "login"
          "oauth"
          "authorize"
        }
        Query {
          Field("client_id", .string.representing(GitHub.Client.ID.self))
          Optionally {
            Field("redirect_uri")
          }
          Field("scope")
          Optionally {
            Field("state") { UUID.parser() }
          }
        }
      }

      Parse {
        Path { "pointfreeco" }

        OneOf(output: GitHubRoute.self) {
          Route(.case(\.organization))

          Route(.case(\.episodeCodeSample)) {
            Path {
              "episode-code-samples"
              "tree"
              "main"
              Parse(.string)
            }
          }

          Route(.case(\.license)) {
            Path {
              "pointfreeco"
              "blob"
              "main"
              "LICENSE"
            }
          }

          Route(.case(\.repo)) {
            Path { GitHubRoute.Repo.parser() }
          }
        }
      }
    }
    .baseURL("https://github.com")
  }
}
