import ApplicativeRouter
import Foundation
import Models
import Parsing
import Prelude
import URLRouting

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
  Route(/Admin.index) {
    Method.get
  }

  Route(/Admin.episodeCredits) {
    Path { "episode-credits" }

    OneOf {
      Route(/Admin.EpisodeCredit.show) {
        Method.get
      }

      Route(/Admin.EpisodeCredit.add(userId:episodeSequence:)) {
        Method.post
        Body {
          FormData {
            Field("user_id", User.Id.parser(rawValue: UUID.parser()))
            Field("episode_sequence", Episode.Sequence.parser(rawValue: Int.parser()))
          }
        }
      }
    }
  }

  Route(/Admin.freeEpisodeEmail) {
    Path { "free-episode-email" }

    OneOf {
      Route(/Admin.FreeEpisodeEmail.index) {
        Method.get
      }

      Route(/Admin.FreeEpisodeEmail.send) {
        Method.get
        Path {
          Episode.Id.parser(rawValue: Int.parser())
          "send"
        }
      }
    }
  }

  Route(/Admin.ghost) {
    Path { "ghost" }

    OneOf {
      Route(/Admin.Ghost.index) {
        Method.get
      }

      Route(/Admin.Ghost.start) {
        Method.post
        Path { "start" }
        Body {
          FormData {
            Field("user_id", User.Id.parser(rawValue: UUID.parser()))
          }
        }
      }
    }
  }

  Route(/Admin.newBlogPostEmail) {
    Path { "new-blog-post-email" }

    OneOf {
      Route(/Admin.NewBlogPostEmail.index) {
        Method.get
      }

      Route(/Admin.NewBlogPostEmail.send) {
        Parse {
          Path {
            BlogPost.Id.parser(rawValue: Int.parser())
            "send"
          }
          Body {
            FormCoded(NewBlogPostFormData.self, decoder: formDecoder)
            FormData {
              isTest
            }
          }
        }
        .pipe(
          Conversion(
            apply: { ($0, $1.0, $1.1) },
            unapply: { ($0, ($1, $2)) }
          )
        )
      }
    }
  }

  Route(/Admin.newEpisodeEmail) {
    Path { "new-episode-email" }

    OneOf {
      Route(/Admin.NewEpisodeEmail.show) {
        Method.get
      }

      Route(/Admin.NewEpisodeEmail.send) {
        Parse {
          Path {
            Episode.Id.parser(rawValue: Int.parser())
            "send"
          }
          Body {
            FormData {
              Optionally {
                Field("subscriber_announcement", String.parser())
              }
              Optionally {
                Field("nonsubscriber_announcement", String.parser())
              }
              isTest
            }
          }
        }
        .pipe(
          Conversion(
            apply: { ($0, $1.0, $1.1, $1.2) },
            unapply: { ($0, ($1, $2, $3)) }
          )
        )
      }
    }
  }
}

private let isTest = Optionally {
  Field(
    "test",
    String.parser().pipe(
      PartialConversion(
        apply: { _ in true },
        unapply: { $0 ? "" : nil }
      )
    )
  )
}
