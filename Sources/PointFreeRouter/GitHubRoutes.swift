import ApplicativeRouter
import Foundation
import GitHub
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

public func gitHubUrl(to route: GitHubRoute) -> String {
  return gitHubRouter.url(for: route, base: gitHubBaseUrl)?.absoluteString ?? ""
}

private let gitHubBaseUrl = URL(string: "https://github.com")!
