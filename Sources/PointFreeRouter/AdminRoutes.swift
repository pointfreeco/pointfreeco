import ApplicativeRouter
import CasePaths
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
  Route(/Admin.index)

  Route(/Admin.episodeCredits) {
    Path { "episode-credits" }

    OneOf {
      Route(/Admin.EpisodeCredit.show)

      Route(/Admin.EpisodeCredit.add(userId:episodeSequence:)) {
        Method.post
        Body {
          FormData {
            Field("user_id") { UUID.parser().map(.representing(User.Id.self)) }
            Field("episode_sequence") { Int.parser().map(.representing(Episode.Sequence.self)) }
          }
        }
      }
    }
  }

  Route(/Admin.freeEpisodeEmail) {
    Path { "free-episode-email" }

    OneOf {
      Route(/Admin.FreeEpisodeEmail.index)

      Route(/Admin.FreeEpisodeEmail.send) {
        Path {
          Int.parser().map(.representing(Episode.Id.self))
          "send"
        }
      }
    }
  }

  Route(/Admin.ghost) {
    Path { "ghost" }

    OneOf {
      Route(/Admin.Ghost.index)

      Route(/Admin.Ghost.start) {
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

  Route(/Admin.newBlogPostEmail) {
    Path { "new-blog-post-email" }

    OneOf {
      Route(/Admin.NewBlogPostEmail.index)

      Route(/Admin.NewBlogPostEmail.send) {
        Method.post
        Parse(
          .convert(
            apply: { ($0, $1.0, $1.1) },
            unapply: { ($0, ($1, $2)) }
          )
        ) {
          Path {
            Int.parser().map(.representing(BlogPost.Id.self))
            "send"
          }
          Body {
            FormCoded(NewBlogPostFormData.self, decoder: formDecoder)
            FormData {
              isTest
            }
          }
        }
      }
    }
  }

  Route(/Admin.newEpisodeEmail) {
    Path { "new-episode-email" }

    OneOf {
      Route(/Admin.NewEpisodeEmail.show)

      Route(/Admin.NewEpisodeEmail.send) {
        Parse(
          .convert(
            apply: { ($0, $1.0, $1.1, $1.2) },
            unapply: { ($0, ($1, $2, $3)) }
          )
        ) {
          Path {
            Int.parser().map(.representing(Episode.Id.self))
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
