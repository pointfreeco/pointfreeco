import Css
import Dependencies
import Either
import Foundation
import HttpPipeline
import HttpPipelineHtmlSupport
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Styleguide
import Tuple
import Views

extension Conn<StatusLineOpen, Void> {
  func showEpisodeCredits() -> Conn<ResponseEnded, Data> {
    self.writeStatus(.ok).respond { showEpisodeCreditsView() }
  }

  func redeemEpisodeCredit(
    _ sequence: Episode.Sequence?, to userID: User.ID?
  ) async -> Conn<ResponseEnded, Data> {
    @Dependency(\.database) var database
    @Dependency(\.episodes) var episodes

    guard let sequence, let episode = episodes().first(where: { $0.sequence == sequence })
    else {
      return self.redirect(to: .admin(.episodeCredits(.show))) {
        $0.flash(.error, "Could not find that episode.")
      }
    }
    guard let userID, let user = try? await database.fetchUserById(userID)
    else {
      return self.redirect(to: .admin(.episodeCredits(.show))) {
        $0.flash(.error, "Could not find that user.")
      }
    }
    do {
      try await database.redeemEpisodeCredit(episode.sequence, user.id)
      return self.redirect(to: .admin(.episodeCredits(.show))) {
        $0.flash(.notice, "Credit redeemed.")
      }
    } catch {
      return self.redirect(to: .admin(.episodeCredits(.show))) {
        $0.flash(.error, "Could not redeem credit.")
      }
    }
  }
}
