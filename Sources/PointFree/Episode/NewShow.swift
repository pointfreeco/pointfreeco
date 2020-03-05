import Either
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

let newEpisodeResponse: M<Tuple4<Either<String, Episode.Id>, User?, SubscriberState, Route?>>
  =
  fetchEpisodeForParam
    <| writeStatus(.ok)
    >=> userEpisodePermission
    >=> map(lower)
    >>> respond(
      view: Views.newEpisodePageView(episodePageData:),
      layoutData: { permission, episode, currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: NewEpisodePageData(
            permission: permission,
            user: currentUser,
            subscriberState: subscriberState,
            episode: episode,
            previousEpisodes: episode.previousEpisodes,
            date: Current.date
          ),
          description: episode.blurb,
          extraStyles: markdownBlockStyles,
          image: episode.image,
          style: .base(.some(.minimal(.black))),
          title: "Episode #\(episode.sequence): \(episode.title)",
          usePrismJs: true
        )
    }
)
