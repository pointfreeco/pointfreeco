import Dependencies
import Foundation
import GitHub
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func betasMiddleware(
  route: SiteRoute.Betas,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  switch route {
  case .landing:
    return await betasLandingMiddleware(conn)
  case .join(let repo):
    return await betasJoinMiddleware(repo: repo, conn: conn)
  }
}

private func betasLandingMiddleware(
  _ conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.envVars.gitHub.betaPreviewsAccessToken) var gitHubAccessToken
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.subscriberState) var subscriberState

  var collaboratorStatuses: [String: Bool] = [:]
  if let currentUser, subscriberState.isMaxSubscriber {
    if let gitHubUser = try? await gitHub.fetchUser(currentUser.gitHubAccessToken) {
      await withTaskGroup(of: (String, Bool).self) { group in
        for beta in Beta.all {
          group.addTask {
            let isCollaborator =
            (
              try? await gitHub.checkRepoCollaborator(
                owner: "pointfreeco",
                repo: beta.repo,
                username: gitHubUser.login,
                token: gitHubAccessToken
              )
            ) ?? false
            return (beta.repo, isCollaborator)
          }
        }
        for await (repo, isCollaborator) in group {
          collaboratorStatuses[repo] = isCollaborator
        }
      }
    }
  }

  return conn
    .writeStatus(.ok)
    .respondV2(
      layoutData: SimplePageLayoutData(
        description: """
          Get early access to the next generation of Point-Free libraries. Join private betas \
          for projects we're actively developing and help shape them before they go public.
          """,
        title: "Private Betas"
      )
    ) {
      BetasLanding(collaboratorStatuses: collaboratorStatuses)
    }
}

private func betasJoinMiddleware(
  repo: String,
  conn: Conn<StatusLineOpen, Void>
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.envVars.gitHub.betaPreviewsAccessToken) var gitHubAccessToken
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.subscriberState) var subscriberState

  guard let currentUser else {
    return conn.loginAndRedirect()
  }
  guard subscriberState.isMaxSubscriber else {
    return conn.redirect(to: .betas()) {
      $0.flash(.error, "You must be a Point-Free Max subscriber to join betas.")
    }
  }
  guard let beta = Beta.all.first(where: { $0.repo == repo }) else {
    return conn.redirect(to: .betas()) {
      $0.flash(.error, "Unknown beta.")
    }
  }
  do {
    let gitHubUser = try await gitHub.fetchUser(currentUser.gitHubAccessToken)
    _ = try await gitHub.addRepoCollaborator(
      owner: "pointfreeco",
      repo: repo,
      username: gitHubUser.login,
      permission: .pull,
      token: gitHubAccessToken
    )
    return conn.redirect(to: .betas()) {
      $0
        .flash(
          .notice,
          """
          You've been invited to the \(beta.title) beta! \
          [Accept your invite on GitHub →](\(beta.repoURL)/invitations)
          """
        )
    }
  } catch {
    return conn.redirect(to: .betas()) {
      $0.flash(.error, "Something went wrong joining the beta. Please try again.")
    }
  }
}
