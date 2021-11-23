import ApplicativeRouter
import Foundation
import GitHub
import Parsing
import Prelude

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

public let gitHubRouter
 = gitHubRouters.reduce(.empty, <|>)

private let gitHubRouters: [Router<GitHubRoute>] = [

  parenthesize(.case(GitHubRoute.authorize))
    <¢> get %> "login" %> "oauth" %> "authorize"
    %> queryParam("client_id", .tagged(.string))
    <%> queryParam("redirect_uri", opt(.string))
    <%> queryParam("scope", .string)
    <% end,

  .case(GitHubRoute.episodeCodeSample)
    <¢> "pointfreeco" %> "episode-code-samples" %> "tree" %> "main"
    %> pathParam(.string)
    <% end,

  .case(.license)
    <¢> "pointfreeco" %> "pointfreeco" %> "blob" %> "main" %> "LICENSE" %> end,

  .case(.organization)
    <¢> get <% "pointfreeco" <% end,

  .case(GitHubRoute.repo)
    <¢> get %> "pointfreeco" %> pathParam(.rawRepresentable) <% end,

]

private let _gitHubRouter = OneOf {
  Routing(/GitHubRoute.authorize) {
    Method.get
    Parse {
      Path("login")
      Path("oauth")
      Path("authorize")
    }
    Query("client_id", String.parser().pipe { GitHub.Client.Id.parser() })
    Optionally {
      Query("redirect_uri", String.parser())
    }
    Query("scope", String.parser())
  }

  Parse {
    Path("pointfreeco")

    OneOf {
      Routing(/GitHubRoute.organization) {
        Method.get
      }

      Routing(/GitHubRoute.episodeCodeSample) {
        Method.get
        Path("episode-code-samples")
        Path("tree")
        Path("main")
        Path(String.parser())
      }

      Routing(/GitHubRoute.license) {
        Method.get
        Path("pointfreeco")
        Path("blob")
        Path("main")
        Path("LICENSE")
      }

      Routing(/GitHubRoute.repo) {
        Method.get
        Path(String.parser().pipe { GitHubRoute.Repo.parser() })
      }
    }
  }
}

public func gitHubUrl(to route: GitHubRoute) -> String {
  return gitHubRouter.url(for: route, base: gitHubBaseUrl)?.absoluteString ?? ""
}

private let gitHubBaseUrl = URL(string: "https://github.com")!
