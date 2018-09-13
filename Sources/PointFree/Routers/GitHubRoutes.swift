import ApplicativeRouter
import Foundation
import Prelude

public enum GitHubRoute: DerivePartialIsos {
  case authorize(clientId: String, redirectUri: String?, scope: String)
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
    case tagged = "swift-tagged"
    case validated = "swift-validated"
    case web = "swift-web"
  }
}

let gitHubRouter = [

  PartialIso.authorize
    <¢> get %> lit("login") %> lit("oauth") %> lit("authorize")
    %> queryParam("client_id", .string)
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

private let gitHubBaseUrl = URL(string: "https://github.com")!

func gitHubUrl(to route: GitHubRoute) -> String {
  return gitHubRouter.url(for: route, base: gitHubBaseUrl)?.absoluteString ?? ""
}
