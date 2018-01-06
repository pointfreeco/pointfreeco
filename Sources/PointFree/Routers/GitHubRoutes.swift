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
    case pointfreeco
    case pointfreecoServer = "pointfreeco-server"
    case prelude = "swift-prelude"
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

private let gitHubBaseUrl = URL(string: "https://www.github.com")!

func gitHubUrl(to route: GitHubRoute) -> String {
  return gitHubRouter.url(for: route, base: gitHubBaseUrl)?.absoluteString ?? ""
}
