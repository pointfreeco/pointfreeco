import ApplicativeRouter
import Foundation
import GitHub
import Prelude

public enum GitHubRoute: DerivePartialIsos {
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

public let gitHubRouter = [

  PartialIso.authorize
    <¢> get %> lit("login") %> lit("oauth") %> lit("authorize")
    %> queryParam("client_id", .tagged(.string))
    <%> queryParam("redirect_uri", opt(.string))
    <%> queryParam("scope", .string)
    <% end,

  .episodeCodeSample
    <¢> lit("pointfreeco") %> lit("episode-code-samples") %> lit("tree") %> lit("master")
    %> pathParam(.string)
    <% end,

  .license
    <¢> lit("pointfreeco") %> lit("pointfreeco") %> lit("blob") %> lit("master") %> lit("LICENSE") %> end,

  .organization
    <¢> get <% lit("pointfreeco") <% end,

  .repo
    <¢> get %> lit("pointfreeco") %> pathParam(.rawRepresentable) <% end,

  ]
  .reduce(.empty, <|>)

public func gitHubUrl(to route: GitHubRoute) -> String {
  return gitHubRouter.url(for: route, base: gitHubBaseUrl)?.absoluteString ?? ""
}

private let gitHubBaseUrl = URL(string: "https://github.com")!
