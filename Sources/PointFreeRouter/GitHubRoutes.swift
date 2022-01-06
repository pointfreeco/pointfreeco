import ApplicativeRouter
import Foundation
import GitHub
import Parsing
import Prelude
import URLRouting

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
    Method.get
    Path {
      "login"
      "oauth"
      "authorize"
    }
    Query {
      Field("client_id", GitHub.Client.Id.parser(rawValue: String.parser()))
      Optionally {
        Field("redirect_uri", String.parser())
      }
      Field("scope", String.parser())
    }
  }

  Parse {
    Path { "pointfreeco" }

    OneOf {
      Route(/GitHubRoute.organization) {
        Method.get
      }

      Route(/GitHubRoute.episodeCodeSample) {
        Method.get
        Path {
          "episode-code-samples"
          "tree"
          "main"
          String.parser()
        }
      }

      Route(/GitHubRoute.license) {
        Method.get
        Path {
          "pointfreeco"
          "blob"
          "main"
          "LICENSE"
        }
      }

      Route(/GitHubRoute.repo) {
        Method.get
        Path { GitHubRoute.Repo.parser(rawValue: String.parser()) }
      }
    }
  }
}

public func gitHubUrl(to route: GitHubRoute) -> String {
  guard let path = gitHubRouter.print(route).flatMap(URLRequest.init(data:))?.url?.absoluteString
  else { return "" }
  return "\(gitHubBaseUrl.absoluteString)/\(path)"
}

private let gitHubBaseUrl = URL(string: "https://github.com")!
