import Foundation
import Models
import URLRouting

public enum EmailTemplate: String, CaseIterable {
  case welcomeEmail1
  case welcomeEmail2
  case welcomeEmail3
}

public enum Admin: Equatable {
  case emailPreview(template: EmailTemplate?)
  case episodeCredits(EpisodeCredit = .show)
  case freeEpisodeEmail(FreeEpisodeEmail = .index)
  case ghost(Ghost = .index)
  case index
  case newBlogPostEmail(NewBlogPostEmail = .index)
  case newEpisodeEmail(NewEpisodeEmail = .show)

  public enum EpisodeCredit: Equatable {
    case add(userId: User.ID?, episodeSequence: Episode.Sequence?)
    case show
  }

  public enum FreeEpisodeEmail: Equatable {
    case send(Episode.ID)
    case index
  }

  public enum Ghost: Equatable {
    case index
    case start(User.ID?)
  }

  public enum NewBlogPostEmail: Equatable {
    case send(BlogPost.ID, formData: NewBlogPostFormData? = nil, isTest: Bool = false)
    case index
  }

  public enum NewEpisodeEmail: Equatable {
    case send(
      Episode.ID,
      subscriberAnnouncement: String = "",
      nonSubscriberAnnouncement: String = "",
      isTest: Bool = false
    )
    case show
  }
}

struct AdminRouter: ParserPrinter {
  var body: some Router<Admin> {
    OneOf {
      Route(.case(Admin.emailPreview(template:))) {
        Path { "email-preview" }
        Optionally {
          Method.post
          Body {
            FormData {
              Field("template", .string.map(.representing(EmailTemplate.self)))
            }
          }
        }
      }

      Route(.case(Admin.index))

      Route(.case(Admin.episodeCredits)) {
        Path { "episode-credits" }

        OneOf {
          Route(.case(Admin.EpisodeCredit.show))

          Route(.case(Admin.EpisodeCredit.add(userId:episodeSequence:))) {
            Method.post
            Body {
              FormData {
                Optionally {
                  Field("user_id") { UUID.parser().map(.representing(User.ID.self)) }
                }
                Optionally {
                  Field("episode_sequence") { Digits().map(.representing(Episode.Sequence.self)) }
                }
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
            Method.post
            Path {
              Digits().map(.representing(Episode.ID.self))
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
                Optionally {
                  Field("user_id") { UUID.parser().map(.representing(User.ID.self)) }
                }
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
            Parse(
              .convert(
                apply: { ($0, $1.0, $1.1) },
                unapply: { ($0, ($1, $2)) }
              )
            ) {
              Method.post
              Path {
                Digits().map(.representing(BlogPost.ID.self))
                "send"
              }
              Body {
                FormData {
                  Optionally {
                    Parse(.memberwise(NewBlogPostFormData.init)) {
                      Field(
                        NewBlogPostFormData.CodingKeys.nonsubscriberAnnouncement.rawValue,
                        default: ""
                      )
                      Field(
                        NewBlogPostFormData.CodingKeys.nonsubscriberDeliver.rawValue, default: false
                      ) {
                        Bool.parser()
                      }
                      Field(
                        NewBlogPostFormData.CodingKeys.subscriberAnnouncement.rawValue,
                        default: ""
                      )
                      Field(
                        NewBlogPostFormData.CodingKeys.subscriberDeliver.rawValue, default: false
                      ) {
                        Bool.parser()
                      }
                    }
                  }
                  Field("test", .string.isPresent, default: false)
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
              Method.post
              Path {
                Digits().map(.representing(Episode.ID.self))
                "send"
              }
              Body {
                FormData {
                  Field("subscriber_announcement", .string, default: "")
                  Field("nonsubscriber_announcement", .string, default: "")
                  Field("test", .string.isPresent, default: false)
                }
              }
            }
          }
        }
      }
    }
  }
}

extension Conversion where Output == String {
  var isPresent: Conversions.Map<Self, AnyConversion<String, Bool>> {
    self.map(
      .convert(
        apply: { _ in true },
        unapply: { $0 ? "" : nil }
      )
    )
  }
}
