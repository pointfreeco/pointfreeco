import ApplicativeRouter
import Prelude

extension Route {
  public enum Admin: DerivePartialIsos {
    case episodeCredits(EpisodeCredit)
    case index
    case newEpisodeEmail(NewEpisodeEmail)

    public enum EpisodeCredit: DerivePartialIsos {
      case add(userId: Database.User.Id?, episodeSequence: Int?)
      case show
    }

    public enum NewEpisodeEmail: DerivePartialIsos {
      case send(Episode.Id)
      case show
    }
  }
}

let adminRouter =
  lit("admin")
    %> adminRouters.reduce(.empty, <|>)

private let adminRouters: [Router<Route>] = [

  .admin <<< .episodeCredits <<< .add
    <¢> post %> lit("episode-credits") %> lit("add")
    %> formField("user_id", Optional.iso.some >>> opt(.uuid >>> .tagged))
    <%> formField("episode_sequence", Optional.iso.some >>> opt(.int))
    <% end,

  .admin <<< .episodeCredits <<< .show
    <¢> get %> lit("episode-credits") %> end,

  .admin <<< .index
    <¢> get <% end,

  .admin <<< .newEpisodeEmail <<< .send
    <¢> post %> lit("new-episode-email") %> pathParam(.int >>> .tagged) <% lit("send") <% end,

  .admin <<< .newEpisodeEmail <<< .show
    <¢> get %> lit("new-episode-email") <% end,
  
]
