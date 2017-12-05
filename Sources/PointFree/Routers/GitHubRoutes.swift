import ApplicativeRouter
import Foundation
import Prelude

public enum GitHubRoute: DerivePartialIsos {
  case authorize(clientId: String, redirectUri: String?, scope: String)
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

  GitHubRoute.iso.organization
    <¢> get <% lit("pointfreeco") <% end,

  GitHubRoute.iso.repo
    <¢> get %> lit("pointfreeco") %> pathParam(.rawRepresentable) <% end,

  GitHubRoute.iso.authorize
    <¢> get %> lit("login") %> lit("oauth") %> lit("authorize")
    %> queryParam("client_id", .string)
    <%> queryParam("redirect_uri", opt(.string))
    <%> queryParam("scope", .string)
    <% end

  ]
  .reduce(.empty, <|>)

private let gitHubBaseUrl = URL(string: "https://www.github.com")!

func gitHubUrl(to route: GitHubRoute) -> String {
  return gitHubRouter.url(for: route, base: gitHubBaseUrl)?.absoluteString ?? ""
}
