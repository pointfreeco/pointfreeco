import Dependencies
import Html
import PointFreeRouter

public func showEpisodeCreditsView() -> Node {
  @Dependency(\.siteRouter) var siteRouter

  return [
    .h3("Create an episode credit!"),
    .form(
      attributes: [
        .method(.post),
        .action(
          siteRouter.path(for: .admin(.episodeCredits(.add(userId: nil, episodeSequence: nil))))),
      ],
      .label("User id:"),
      .input(attributes: [.type(.text), .name("user_id")]),
      .label("Episode sequence #:"),
      .input(attributes: [.type(.text), .name("episode_sequence")]),
      .input(attributes: [.type(.submit), .value("Create")])
    ),
  ]
}
