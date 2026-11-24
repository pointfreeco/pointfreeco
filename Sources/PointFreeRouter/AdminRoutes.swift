import CasePaths
import Foundation
import Models
import URLRouting

public enum EmailTemplate: String, CaseIterable {
  case joinTeamConfirmation
  case loginCode
  case maxWelcomeEmail
  case proWelcomeEmail
  case newBlogPost
  case newEpisode
  case newTeammateJoined
  case ownerNewTeammateJoined
  case updateGitHubAccount
  case welcomeEmail1
  case welcomeEmail2
  case welcomeEmail3
}

@CasePathable
public enum Admin: Equatable {
  case emailPreview(EmailPreview = .show(template: nil))
  case episodeCredits(EpisodeCredit = .show)
  case freeEpisodeEmail(FreeEpisodeEmail = .index)
  case ghost(Ghost = .index)
  case index
  case newBlogPostEmail(NewBlogPostEmail = .index)
  case newEpisodeEmail(NewEpisodeEmail = .show)

  @CasePathable
  public enum EmailPreview: Equatable {
    case send(template: EmailTemplate, email: String)
    case show(template: EmailTemplate?)
  }

  @CasePathable
  public enum EpisodeCredit: Equatable {
    case add(userId: User.ID?, episodeSequence: Episode.Sequence?)
    case show
  }

  @CasePathable
  public enum FreeEpisodeEmail: Equatable {
    case send(Episode.ID)
    case index
  }

  @CasePathable
  public enum Ghost: Equatable {
    case index
    case start(User.ID?)
  }

  @CasePathable
  public enum NewBlogPostEmail: Equatable {
    case send(BlogPost.ID, formData: NewBlogPostFormData? = nil, isTest: Bool = false)
    case index
  }

  @CasePathable
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
    OneOf(output: Admin.self) {
      Route(.case(\.emailPreview)) {
        Path { "email-preview" }

        OneOf(output: Admin.EmailPreview.self) {
          Route(.case(Admin.EmailPreview.send(template:email:))) {
            Method.post
            Body {
              FormData {
                Field("template", .string.map(.representing(EmailTemplate.self)))
                Field("email")
              }
            }
          }

          Route(.case(\.show)) {
            Optionally {
              Method.post
              Body {
                FormData {
                  Field("template", .string.map(.representing(EmailTemplate.self)))
                }
              }
            }
          }
        }
      }

      Route(.case(\.index))

      Route(.case(\.episodeCredits)) {
        Path { "episode-credits" }

        OneOf(output: Admin.EpisodeCredit.self) {
          Route(.case(\.show))

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

      Route(.case(\.freeEpisodeEmail)) {
        Path { "free-episode-email" }

        OneOf(output: Admin.FreeEpisodeEmail.self) {
          Route(.case(\.index))

          Route(.case(\.send)) {
            Method.post
            Path {
              Digits().map(.representing(Episode.ID.self))
              "send"
            }
          }
        }
      }

      Route(.case(\.ghost)) {
        Path { "ghost" }

        OneOf(output: Admin.Ghost.self) {
          Route(.case(\.index))

          Route(.case(\.start)) {
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

      Route(.case(\.newBlogPostEmail)) {
        Path { "new-blog-post-email" }

        OneOf(output: Admin.NewBlogPostEmail.self) {
          Route(.case(\.index))

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
                        NewBlogPostFormData.CodingKeys.maxSubscriberDeliver.rawValue, default: false
                      ) {
                        Bool.parser()
                      }
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

      Route(.case(\.newEpisodeEmail)) {
        Path { "new-episode-email" }

        OneOf(output: Admin.NewEpisodeEmail.self) {
          Route(.case(\.show))

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
