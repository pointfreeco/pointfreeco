import ApplicativeRouter
import Foundation
import GitHub
import Parsing
import Prelude
import _URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum GitHubRoute {
  case authorize(clientId: GitHub.Client.Id, redirectUri: String?, scope: String)
  case episodeCodeSample(directory: String)
  case license
  case organization
  case repo(Repo)

  public enum Repo: String, RawRepresentable {
    case html = "swift-html"
    case htmlKitura = "swift-html-kitura"
    case htmlVapor = "swift-html-vapor"
    case nonempty = "swift-nonempty"
    case overture = "swift-overture"
    case pointfreeco
    case prelude = "swift-prelude"
    case snapshotTesting = "swift-snapshot-testing"
    case tagged = "swift-tagged"
    case validated = "swift-validated"
    case web = "swift-web"
  }
}

private let gitHubRouter = OneOf {
  Route(/GitHubRoute.authorize) {
    Path {
      "login"
      "oauth"
      "authorize"
    }
    Query {
      Field("client_id", Parse(.string.representing(GitHub.Client.Id.self)))
      Optionally {
        Field("redirect_uri", Parse(.string))
      }
      Field("scope", Parse(.string))
    }
  }

  Parse {
    Path { "pointfreeco" }

    OneOf {
      Route(/GitHubRoute.organization)

      Route(/GitHubRoute.episodeCodeSample) {
        Path {
          "episode-code-samples"
          "tree"
          "main"
          Parse(.string)
        }
      }

      Route(/GitHubRoute.license) {
        Path {
          "pointfreeco"
          "blob"
          "main"
          "LICENSE"
        }
      }

      Route(/GitHubRoute.repo) {
        Path { Parse(.string.representing(GitHubRoute.Repo.self)) }
      }
    }
  }
}

public func gitHubUrl(to route: GitHubRoute) -> String {
  guard
    let path = (try? gitHubRouter.print(route)).flatMap(URLRequest.init(data:))?.url?.absoluteString
  else { return "" }
  return "\(gitHubBaseUrl.absoluteString)/\(path)"
}

private let gitHubBaseUrl = URL(string: "https://github.com")!
