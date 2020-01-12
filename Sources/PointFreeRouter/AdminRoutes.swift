import ApplicativeRouter
import Models
import Prelude

public enum Admin: Equatable {
  case episodeCredits(EpisodeCredit)
  case freeEpisodeEmail(FreeEpisodeEmail)
  case ghost(Ghost)
  case index
  case newBlogPostEmail(NewBlogPostEmail)
  case newEpisodeEmail(NewEpisodeEmail)

  public enum EpisodeCredit: Equatable {
    case add(userId: User.Id?, episodeSequence: Int?)
    case show
  }

  public enum FreeEpisodeEmail: Equatable {
    case send(Episode.Id)
    case index
  }

  public enum Ghost: Equatable {
    case index
    case start(User.Id?)
  }

  public enum NewBlogPostEmail: Equatable {
    case send(BlogPost.Id, formData: NewBlogPostFormData?, isTest: Bool?)
    case index
  }

  public enum NewEpisodeEmail: Equatable {
    case send(Episode.Id, subscriberAnnouncement: String?, nonSubscriberAnnouncement: String?, isTest: Bool?)
    case show
  }
}

public let adminRouter = adminRouters.reduce(.empty, <|>)

private let adminRouters: [Router<Admin>] = [
  .case { .episodeCredits(.add(userId: $0, episodeSequence: $1)) }
    <¢> post %> lit("episode-credits") %> lit("add")
    %> formField("user_id", Optional.iso.some >>> opt(.tagged(.uuid)))
    <%> formField("episode_sequence", Optional.iso.some >>> opt(.int))
    <% end,

  .case(const(.episodeCredits(.show)))
    <¢> get %> lit("episode-credits") %> end,

  .case(const(.index))
    <¢> get <% end,

  .case { .freeEpisodeEmail(.send($0)) }
    <¢> post %> lit("free-episode-email") %> pathParam(.tagged(.int)) <% lit("send") <% end,

  .case(const(.freeEpisodeEmail(.index)))
    <¢> get %> lit("free-episode-email") <% end,

  .case(const(.ghost(.index)))
    <¢> get %> "ghost" <% end,

  .case { .ghost(.start($0)) }
    <¢> post %> "ghost" %> "start"
    %> formField("user_id", .tagged(.uuid)).map(Optional.iso.some)
    <% end,

  .case(const(.newBlogPostEmail(.index)))
    <¢> get %> lit("new-blog-post-email") <% end,

  parenthesize(.case { .newBlogPostEmail(.send($0, formData: $1, isTest: $2)) })
    <¢> post %> lit("new-blog-post-email") %> pathParam(.tagged(.int)) <%> lit("send")
    %> formBody(NewBlogPostFormData?.self, decoder: formDecoder)
    <%> isTest
    <% end,

  .case(Admin.newEpisodeEmail) <<< parenthesize(.case(Admin.NewEpisodeEmail.send))
    <¢> post %> lit("new-episode-email") %> pathParam(.tagged(.int)) <%> lit("send")
    %> formField("subscriber_announcement", .string).map(Optional.iso.some)
    <%> formField("nonsubscriber_announcement", .string).map(Optional.iso.some)
    <%> isTest
    <% end,

  .case(const(.newEpisodeEmail(.show)))
    <¢> get %> lit("new-episode-email") <% end,
]
