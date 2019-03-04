import ApplicativeRouter
import Models
import Prelude

public enum Admin: DerivePartialIsos, Equatable {
  case episodeCredits(EpisodeCredit)
  case freeEpisodeEmail(FreeEpisodeEmail)
  case index
  case newBlogPostEmail(NewBlogPostEmail)
  case newEpisodeEmail(NewEpisodeEmail)

  public enum EpisodeCredit: DerivePartialIsos, Equatable {
    case add(userId: User.Id?, episodeSequence: Int?)
    case show
  }

  public enum FreeEpisodeEmail: DerivePartialIsos, Equatable {
    case send(Episode.Id)
    case index
  }

  public enum NewBlogPostEmail: DerivePartialIsos, Equatable {
    case send(BlogPost.Id, formData: NewBlogPostFormData?, isTest: Bool?)
    case index
  }

  public enum NewEpisodeEmail: DerivePartialIsos, Equatable {
    case send(Episode.Id, subscriberAnnouncement: String?, nonSubscriberAnnouncement: String?, isTest: Bool?)
    case show
  }
}

public let adminRouter = routers.reduce(.empty, <|>)

private let routers: [Router<Admin>] = [
  .episodeCredits <<< .add
    <¢> post %> lit("episode-credits") %> lit("add")
    %> formField("user_id", Optional.iso.some >>> opt(.uuid >>> .tagged))
    <%> formField("episode_sequence", Optional.iso.some >>> opt(.int))
    <% end,

  .episodeCredits <<< .show
    <¢> get %> lit("episode-credits") %> end,

  .index
    <¢> get <% end,

  .freeEpisodeEmail <<< .send
    <¢> post %> lit("free-episode-email") %> pathParam(.int >>> .tagged) <% lit("send") <% end,

  .freeEpisodeEmail <<< .index
    <¢> get %> lit("free-episode-email") <% end,

  .newBlogPostEmail <<< .index
    <¢> get %> lit("new-blog-post-email") <% end,

  .newBlogPostEmail <<< PartialIso.send
    <¢> post %> lit("new-blog-post-email") %> pathParam(.int >>> .tagged) <%> lit("send")
    %> formBody(NewBlogPostFormData?.self, decoder: formDecoder)
    <%> isTest
    <% end,

  .newEpisodeEmail <<< PartialIso.send
    <¢> post %> lit("new-episode-email") %> pathParam(.int >>> .tagged) <%> lit("send")
    %> formField("subscriber_announcement", .string).map(Optional.iso.some)
    <%> formField("nonsubscriber_announcement", .string).map(Optional.iso.some)
    <%> isTest
    <% end,

  .newEpisodeEmail <<< .show
    <¢> get %> lit("new-episode-email") <% end,
]
