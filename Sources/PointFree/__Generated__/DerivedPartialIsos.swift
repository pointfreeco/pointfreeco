// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import ApplicativeRouter
import Prelude

  extension GitHubRoute {
    enum iso {
          public static let authorize = parenthesize <| PartialIso(
            apply: GitHubRoute.authorize,
            unapply: {
              guard case let .authorize(result) = $0 else { return nil }
              return result
          })
          public static let episodeCodeSample = parenthesize <| PartialIso(
            apply: GitHubRoute.episodeCodeSample,
            unapply: {
              guard case let .episodeCodeSample(result) = $0 else { return nil }
              return result
          })
          public static let license = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
            apply: const(.some(.license)),
            unapply: {
              guard case .license = $0 else { return nil }
              return unit
          })
          public static let organization = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
            apply: const(.some(.organization)),
            unapply: {
              guard case .organization = $0 else { return nil }
              return unit
          })
          public static let repo = parenthesize <| PartialIso(
            apply: GitHubRoute.repo,
            unapply: {
              guard case let .repo(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Pricing {
    enum iso {
          public static let individual = parenthesize <| PartialIso(
            apply: Pricing.individual,
            unapply: {
              guard case let .individual(result) = $0 else { return nil }
              return result
          })
          public static let team = parenthesize <| PartialIso(
            apply: Pricing.team,
            unapply: {
              guard case let .team(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route {
    enum iso {
          public static let about = parenthesize <| PartialIso<Prelude.Unit, Route>(
            apply: const(.some(.about)),
            unapply: {
              guard case .about = $0 else { return nil }
              return unit
          })
          public static let account = parenthesize <| PartialIso(
            apply: Route.account,
            unapply: {
              guard case let .account(result) = $0 else { return nil }
              return result
          })
          public static let admin = parenthesize <| PartialIso(
            apply: Route.admin,
            unapply: {
              guard case let .admin(result) = $0 else { return nil }
              return result
          })
          public static let episode = parenthesize <| PartialIso(
            apply: Route.episode,
            unapply: {
              guard case let .episode(result) = $0 else { return nil }
              return result
          })
          public static let expressUnsubscribe = parenthesize <| PartialIso(
            apply: Route.expressUnsubscribe,
            unapply: {
              guard case let .expressUnsubscribe(result) = $0 else { return nil }
              return result
          })
          public static let gitHubCallback = parenthesize <| PartialIso(
            apply: Route.gitHubCallback,
            unapply: {
              guard case let .gitHubCallback(result) = $0 else { return nil }
              return result
          })
          public static let home = parenthesize <| PartialIso(
            apply: Route.home,
            unapply: {
              guard case let .home(result) = $0 else { return nil }
              return result
          })
          public static let invite = parenthesize <| PartialIso(
            apply: Route.invite,
            unapply: {
              guard case let .invite(result) = $0 else { return nil }
              return result
          })
          public static let launchSignup = parenthesize <| PartialIso(
            apply: Route.launchSignup,
            unapply: {
              guard case let .launchSignup(result) = $0 else { return nil }
              return result
          })
          public static let login = parenthesize <| PartialIso(
            apply: Route.login,
            unapply: {
              guard case let .login(result) = $0 else { return nil }
              return result
          })
          public static let logout = parenthesize <| PartialIso<Prelude.Unit, Route>(
            apply: const(.some(.logout)),
            unapply: {
              guard case .logout = $0 else { return nil }
              return unit
          })
          public static let pricing = parenthesize <| PartialIso(
            apply: Route.pricing,
            unapply: {
              guard case let .pricing(result) = $0 else { return nil }
              return result
          })
          public static let secretHome = parenthesize <| PartialIso<Prelude.Unit, Route>(
            apply: const(.some(.secretHome)),
            unapply: {
              guard case .secretHome = $0 else { return nil }
              return unit
          })
          public static let subscribe = parenthesize <| PartialIso(
            apply: Route.subscribe,
            unapply: {
              guard case let .subscribe(result) = $0 else { return nil }
              return result
          })
          public static let team = parenthesize <| PartialIso(
            apply: Route.team,
            unapply: {
              guard case let .team(result) = $0 else { return nil }
              return result
          })
          public static let terms = parenthesize <| PartialIso<Prelude.Unit, Route>(
            apply: const(.some(.terms)),
            unapply: {
              guard case .terms = $0 else { return nil }
              return unit
          })
    }
  }
  extension Route.Account {
    enum iso {
          public static let confirmEmailChange = parenthesize <| PartialIso(
            apply: Route.Account.confirmEmailChange,
            unapply: {
              guard case let .confirmEmailChange(result) = $0 else { return nil }
              return result
          })
          public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Account>(
            apply: const(.some(.index)),
            unapply: {
              guard case .index = $0 else { return nil }
              return unit
          })
          public static let paymentInfo = parenthesize <| PartialIso(
            apply: Route.Account.paymentInfo,
            unapply: {
              guard case let .paymentInfo(result) = $0 else { return nil }
              return result
          })
          public static let subscription = parenthesize <| PartialIso(
            apply: Route.Account.subscription,
            unapply: {
              guard case let .subscription(result) = $0 else { return nil }
              return result
          })
          public static let update = parenthesize <| PartialIso(
            apply: Route.Account.update,
            unapply: {
              guard case let .update(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route.Account.PaymentInfo {
    enum iso {
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Account.PaymentInfo>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
          public static let update = parenthesize <| PartialIso(
            apply: Route.Account.PaymentInfo.update,
            unapply: {
              guard case let .update(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route.Account.Subscription {
    enum iso {
          public static let cancel = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.cancel,
            unapply: {
              guard case let .cancel(result) = $0 else { return nil }
              return result
          })
          public static let changeSeats = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.changeSeats,
            unapply: {
              guard case let .changeSeats(result) = $0 else { return nil }
              return result
          })
          public static let downgrade = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.downgrade,
            unapply: {
              guard case let .downgrade(result) = $0 else { return nil }
              return result
          })
          public static let reactivate = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription>(
            apply: const(.some(.reactivate)),
            unapply: {
              guard case .reactivate = $0 else { return nil }
              return unit
          })
          public static let upgrade = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.upgrade,
            unapply: {
              guard case let .upgrade(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route.Account.Subscription.Cancel {
    enum iso {
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Cancel>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
          public static let update = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Cancel>(
            apply: const(.some(.update)),
            unapply: {
              guard case .update = $0 else { return nil }
              return unit
          })
    }
  }
  extension Route.Account.Subscription.ChangeSeats {
    enum iso {
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.ChangeSeats>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
          public static let update = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.ChangeSeats.update,
            unapply: {
              guard case let .update(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route.Account.Subscription.Downgrade {
    enum iso {
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Downgrade>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
          public static let update = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Downgrade>(
            apply: const(.some(.update)),
            unapply: {
              guard case .update = $0 else { return nil }
              return unit
          })
    }
  }
  extension Route.Account.Subscription.Upgrade {
    enum iso {
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Upgrade>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
          public static let update = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Upgrade>(
            apply: const(.some(.update)),
            unapply: {
              guard case .update = $0 else { return nil }
              return unit
          })
    }
  }
  extension Route.Admin {
    enum iso {
          public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Admin>(
            apply: const(.some(.index)),
            unapply: {
              guard case .index = $0 else { return nil }
              return unit
          })
          public static let newEpisodeEmail = parenthesize <| PartialIso(
            apply: Route.Admin.newEpisodeEmail,
            unapply: {
              guard case let .newEpisodeEmail(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route.Admin.NewEpisodeEmail {
    enum iso {
          public static let send = parenthesize <| PartialIso(
            apply: Route.Admin.NewEpisodeEmail.send,
            unapply: {
              guard case let .send(result) = $0 else { return nil }
              return result
          })
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Admin.NewEpisodeEmail>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
    }
  }
  extension Route.Invite {
    enum iso {
          public static let accept = parenthesize <| PartialIso(
            apply: Route.Invite.accept,
            unapply: {
              guard case let .accept(result) = $0 else { return nil }
              return result
          })
          public static let resend = parenthesize <| PartialIso(
            apply: Route.Invite.resend,
            unapply: {
              guard case let .resend(result) = $0 else { return nil }
              return result
          })
          public static let revoke = parenthesize <| PartialIso(
            apply: Route.Invite.revoke,
            unapply: {
              guard case let .revoke(result) = $0 else { return nil }
              return result
          })
          public static let send = parenthesize <| PartialIso(
            apply: Route.Invite.send,
            unapply: {
              guard case let .send(result) = $0 else { return nil }
              return result
          })
          public static let show = parenthesize <| PartialIso(
            apply: Route.Invite.show,
            unapply: {
              guard case let .show(result) = $0 else { return nil }
              return result
          })
    }
  }
  extension Route.Team {
    enum iso {
          public static let remove = parenthesize <| PartialIso(
            apply: Route.Team.remove,
            unapply: {
              guard case let .remove(result) = $0 else { return nil }
              return result
          })
          public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Team>(
            apply: const(.some(.show)),
            unapply: {
              guard case .show = $0 else { return nil }
              return unit
          })
    }
  }
  extension TwitterRoute {
    enum iso {
          public static let mbrandonw = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
            apply: const(.some(.mbrandonw)),
            unapply: {
              guard case .mbrandonw = $0 else { return nil }
              return unit
          })
          public static let pointfreeco = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
            apply: const(.some(.pointfreeco)),
            unapply: {
              guard case .pointfreeco = $0 else { return nil }
              return unit
          })
          public static let stephencelis = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
            apply: const(.some(.stephencelis)),
            unapply: {
              guard case .stephencelis = $0 else { return nil }
              return unit
          })
    }
  }
