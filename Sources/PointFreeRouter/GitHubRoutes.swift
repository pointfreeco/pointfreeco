import GitHub
import URLRouting

public enum GitHubRoute {
  case authorize(clientId: GitHub.Client.ID, redirectUri: String?, scope: String)
  case episodeCodeSample(directory: String)
  case license
  case organization
  case repo(Repo)

  public enum Repo: String, CaseIterable {
    case html = "swift-html"
    case htmlKitura = "swift-html-kitura"
    case htmlVapor = "swift-html-vapor"
    case nonempty = "swift-nonempty"
    case overture = "swift-overture"
    case parsing = "swift-parsing"
    case pointfreeco
    case prelude = "swift-prelude"
    case snapshotTesting = "swift-snapshot-testing"
    case tagged = "swift-tagged"
    case validated = "swift-validated"
    case web = "swift-web"
  }
}

public let gitHubRouter = OneOf {
  Route(.case(GitHubRoute.authorize)) {
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
    }
  }

  Parse {
    Path { "pointfreeco" }

    OneOf {
      Route(.case(GitHubRoute.organization))

      Route(.case(GitHubRoute.episodeCodeSample)) {
        Path {
          "episode-code-samples"
          "tree"
          "main"
          Parse(.string)
        }
      }

      Route(.case(GitHubRoute.license)) {
        Path {
          "pointfreeco"
          "blob"
          "main"
          "LICENSE"
        }
      }

      Route(.case(GitHubRoute.repo)) {
        Path { GitHubRoute.Repo.parser() }
      }
    }
  }
}
.baseURL("https://github.com")
