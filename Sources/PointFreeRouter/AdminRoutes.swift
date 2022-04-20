import Foundation
import Models
import Parsing
import Prelude
import _URLRouting

public enum Admin: Equatable {
  case episodeCredits(EpisodeCredit)
  case freeEpisodeEmail(FreeEpisodeEmail)
  case ghost(Ghost)
  case index
  case newBlogPostEmail(NewBlogPostEmail)
  case newEpisodeEmail(NewEpisodeEmail)

  public enum EpisodeCredit: Equatable {
    case add(userId: User.Id?, episodeSequence: Episode.Sequence?)
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

let adminRouter = OneOf {
  Route(.case(Admin.index))

  Route(.case(Admin.episodeCredits)) {
    Path { "episode-credits" }

    OneOf {
      Route(.case(Admin.EpisodeCredit.show))

      Route(.case(Admin.EpisodeCredit.add(userId:episodeSequence:))) {
        Method.post
        Body {
          FormData {
            Field("user_id") { UUID.parser().map(.representing(User.Id.self)) }
            Field("episode_sequence") { Digits().map(.representing(Episode.Sequence.self)) }
          }
        }
      }
    }
  }

  Route(.case(Admin.freeEpisodeEmail)) {
    Path { "free-episode-email" }

    OneOf {
      Route(.case(Admin.FreeEpisodeEmail.index))

      Route(.case(Admin.FreeEpisodeEmail.send)) {
        Path {
          Digits().map(.representing(Episode.Id.self))
          "send"
        }
      }
    }
  }

  Route(.case(Admin.ghost)) {
    Path { "ghost" }

    OneOf {
      Route(.case(Admin.Ghost.index))

      Route(.case(Admin.Ghost.start)) {
        Method.post
        Path { "start" }
        Body {
          FormData {
            Field("user_id") { UUID.parser().map(.representing(User.Id.self)) }
          }
        }
      }
    }
  }

  Route(.case(Admin.newBlogPostEmail)) {
    Path { "new-blog-post-email" }

    OneOf {
      Route(.case(Admin.NewBlogPostEmail.index))

      Route(.case(Admin.NewBlogPostEmail.send)) {
        Method.post

        Parse(
          .convert(
            apply: { ($0, $1.0, $1.1) },
            unapply: { ($0, ($1, $2)) }
          )
        ) {
          Path {
            Digits().map(.representing(BlogPost.Id.self))
            "send"
          }
          Body {
            FormData {
              Parse(.memberwise(NewBlogPostFormData.init)) {
                Field(
                  NewBlogPostFormData.CodingKeys.nonsubscriberAnnouncement.rawValue,
                  .string,
                  default: ""
                )
                Optionally {
                  Field(NewBlogPostFormData.CodingKeys.nonsubscriberDeliver.rawValue) {
                    Bool.parser()
                  }
                }
                Field(
                  NewBlogPostFormData.CodingKeys.subscriberAnnouncement.rawValue,
                  .string,
                  default: ""
                )
                Optionally {
                  Field(NewBlogPostFormData.CodingKeys.subscriberDeliver.rawValue) { Bool.parser() }
                }
              }
              isTest
            }
          }
        }
      }
    }
  }

  Route(.case(Admin.newEpisodeEmail)) {
    Path { "new-episode-email" }

    OneOf {
      Route(.case(Admin.NewEpisodeEmail.show))

      Route(.case(Admin.NewEpisodeEmail.send)) {
        Parse(
          .convert(
            apply: { ($0, $1.0, $1.1, $1.2) },
            unapply: { ($0, ($1, $2, $3)) }
          )
        ) {
          Path {
            Digits().map(.representing(Episode.Id.self))
            "send"
          }
          Body {
            FormData {
              Optionally {
                Field("subscriber_announcement", .string)
              }
              Optionally {
                Field("nonsubscriber_announcement", .string)
              }
              isTest
            }
          }
        }
      }
    }
  }
}

private let isTest = Optionally {
  Field(
    "test",
    .string.map(
      .convert(
        apply: { _ in true },
        unapply: { $0 ? "" : nil }
      )
    )
  )
}
