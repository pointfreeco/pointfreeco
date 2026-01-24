import Dependencies
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import StyleguideV2
import Views

func showEpisodeCreditsMiddleware(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn.writeStatus(.ok)
    .respondV2(layoutData: SimplePageLayoutData(title: "Episode credits")) {
      EpisodeCreditView()
    }
}

func redeemEpisodeCreditMiddleware(
  _ conn: Conn<StatusLineOpen, Void>,
  userID: User.ID?,
  episodeSequence: Episode.Sequence?
) async -> Conn<ResponseEnded, Data> {
  @Dependency(\.database) var database
  guard let userID, let user = try? await database.fetchUser(id: userID) else {
    return conn.redirect(to: .admin(.episodeCredits(.show))) {
      $0.flash(.error, "Could not find that user.")
    }
  }
  guard let episode = fetchEpisode(bySequence: episodeSequence) else {
    return conn.redirect(to: .admin(.episodeCredits(.show))) {
      $0.flash(.error, "Could not find that episode.")
    }
  }
  do {
    try await database.redeemEpisodeCredit(sequence: episode.sequence, userID: user.id)
    return conn.redirect(to: .admin(.episodeCredits(.show))) {
      $0.flash(.notice, "Applied credit!")
    }
  } catch {
    return conn.redirect(to: .admin(.episodeCredits(.show))) {
      $0.flash(.error, "Could not apply credit.")
    }
  }
}

private func fetchEpisode(bySequence sequence: Episode.Sequence?) -> Episode? {
  @Dependency(\.episodes) var episodes

  guard let sequence = sequence else { return nil }
  return episodes()
    .first(where: { $0.sequence == sequence })
}
