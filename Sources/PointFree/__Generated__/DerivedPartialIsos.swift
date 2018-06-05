// Generated using Sourcery 0.11.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import ApplicativeRouter
import Either
import Prelude



      extension PartialIso where A == (
            String
          , 
            String?
          , 
            String
        ), B == GitHubRoute {

          public static let authorize = parenthesize <| PartialIso(
            apply: GitHubRoute.authorize,
            unapply: {
              guard case let .authorize(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            String
        ), B == GitHubRoute {

          public static let episodeCodeSample = parenthesize <| PartialIso(
            apply: GitHubRoute.episodeCodeSample,
            unapply: {
              guard case let .episodeCodeSample(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == GitHubRoute {
        public static let license = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
          apply: const(.some(.license)),
          unapply: {
            guard case .license = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == GitHubRoute {
        public static let organization = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
          apply: const(.some(.organization)),
          unapply: {
            guard case .organization = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            GitHubRoute.Repo
        ), B == GitHubRoute {

          public static let repo = parenthesize <| PartialIso(
            apply: GitHubRoute.repo,
            unapply: {
              guard case let .repo(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route {
        public static let about = parenthesize <| PartialIso<Prelude.Unit, Route>(
          apply: const(.some(.about)),
          unapply: {
            guard case .about = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Route.Account
        ), B == Route {

          public static let account = parenthesize <| PartialIso(
            apply: Route.account,
            unapply: {
              guard case let .account(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Admin
        ), B == Route {

          public static let admin = parenthesize <| PartialIso(
            apply: Route.admin,
            unapply: {
              guard case let .admin(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route {
        public static let appleDeveloperMerchantIdDomainAssociation = parenthesize <| PartialIso<Prelude.Unit, Route>(
          apply: const(.some(.appleDeveloperMerchantIdDomainAssociation)),
          unapply: {
            guard case .appleDeveloperMerchantIdDomainAssociation = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Route.Blog
        ), B == Route {

          public static let blog = parenthesize <| PartialIso(
            apply: Route.blog,
            unapply: {
              guard case let .blog(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Either<String, Int>
        ), B == Route {

          public static let episode = parenthesize <| PartialIso(
            apply: Route.episode,
            unapply: {
              guard case let .episode(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route {
        public static let episodes = parenthesize <| PartialIso<Prelude.Unit, Route>(
          apply: const(.some(.episodes)),
          unapply: {
            guard case .episodes = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Database.User.Id
          , 
            Database.EmailSetting.Newsletter
        ), B == Route {

          public static let expressUnsubscribe = parenthesize <| PartialIso(
            apply: Route.expressUnsubscribe,
            unapply: {
              guard case let .expressUnsubscribe(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            MailgunForwardPayload
        ), B == Route {

          public static let expressUnsubscribeReply = parenthesize <| PartialIso(
            apply: Route.expressUnsubscribeReply,
            unapply: {
              guard case let .expressUnsubscribeReply(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Feed
        ), B == Route {

          public static let feed = parenthesize <| PartialIso(
            apply: Route.feed,
            unapply: {
              guard case let .feed(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            String?
          , 
            String?
        ), B == Route {

          public static let gitHubCallback = parenthesize <| PartialIso(
            apply: Route.gitHubCallback,
            unapply: {
              guard case let .gitHubCallback(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Invite
        ), B == Route {

          public static let invite = parenthesize <| PartialIso(
            apply: Route.invite,
            unapply: {
              guard case let .invite(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            String?
        ), B == Route {

          public static let login = parenthesize <| PartialIso(
            apply: Route.login,
            unapply: {
              guard case let .login(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route {
        public static let logout = parenthesize <| PartialIso<Prelude.Unit, Route>(
          apply: const(.some(.logout)),
          unapply: {
            guard case .logout = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Pricing?
          , 
            Bool?
        ), B == Route {

          public static let pricing = parenthesize <| PartialIso(
            apply: Route.pricing,
            unapply: {
              guard case let .pricing(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route {
        public static let privacy = parenthesize <| PartialIso<Prelude.Unit, Route>(
          apply: const(.some(.privacy)),
          unapply: {
            guard case .privacy = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == Route {
        public static let home = parenthesize <| PartialIso<Prelude.Unit, Route>(
          apply: const(.some(.home)),
          unapply: {
            guard case .home = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            SubscribeData?
        ), B == Route {

          public static let subscribe = parenthesize <| PartialIso(
            apply: Route.subscribe,
            unapply: {
              guard case let .subscribe(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Team
        ), B == Route {

          public static let team = parenthesize <| PartialIso(
            apply: Route.team,
            unapply: {
              guard case let .team(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Episode.Id
        ), B == Route {

          public static let useEpisodeCredit = parenthesize <| PartialIso(
            apply: Route.useEpisodeCredit,
            unapply: {
              guard case let .useEpisodeCredit(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Webhooks
        ), B == Route {

          public static let webhooks = parenthesize <| PartialIso(
            apply: Route.webhooks,
            unapply: {
              guard case let .webhooks(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Database.User.Id
          , 
            EmailAddress
        ), B == Route.Account {

          public static let confirmEmailChange = parenthesize <| PartialIso(
            apply: Route.Account.confirmEmailChange,
            unapply: {
              guard case let .confirmEmailChange(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Account {
        public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Account>(
          apply: const(.some(.index)),
          unapply: {
            guard case .index = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Route.Account.Invoices
        ), B == Route.Account {

          public static let invoices = parenthesize <| PartialIso(
            apply: Route.Account.invoices,
            unapply: {
              guard case let .invoices(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Account.PaymentInfo
        ), B == Route.Account {

          public static let paymentInfo = parenthesize <| PartialIso(
            apply: Route.Account.paymentInfo,
            unapply: {
              guard case let .paymentInfo(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Account.Subscription
        ), B == Route.Account {

          public static let subscription = parenthesize <| PartialIso(
            apply: Route.Account.subscription,
            unapply: {
              guard case let .subscription(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            ProfileData?
        ), B == Route.Account {

          public static let update = parenthesize <| PartialIso(
            apply: Route.Account.update,
            unapply: {
              guard case let .update(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Account.Invoices {
        public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Invoices>(
          apply: const(.some(.index)),
          unapply: {
            guard case .index = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Stripe.Invoice.Id
        ), B == Route.Account.Invoices {

          public static let show = parenthesize <| PartialIso(
            apply: Route.Account.Invoices.show,
            unapply: {
              guard case let .show(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Bool?
        ), B == Route.Account.PaymentInfo {

          public static let show = parenthesize <| PartialIso(
            apply: Route.Account.PaymentInfo.show,
            unapply: {
              guard case let .show(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Stripe.Token.Id?
        ), B == Route.Account.PaymentInfo {

          public static let update = parenthesize <| PartialIso(
            apply: Route.Account.PaymentInfo.update,
            unapply: {
              guard case let .update(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Account.Subscription {
        public static let cancel = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription>(
          apply: const(.some(.cancel)),
          unapply: {
            guard case .cancel = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Route.Account.Subscription.Change
        ), B == Route.Account.Subscription {

          public static let change = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.change,
            unapply: {
              guard case let .change(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Account.Subscription {
        public static let reactivate = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription>(
          apply: const(.some(.reactivate)),
          unapply: {
            guard case .reactivate = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Account.Subscription.Change {
        public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Account.Subscription.Change>(
          apply: const(.some(.show)),
          unapply: {
            guard case .show = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Pricing?
        ), B == Route.Account.Subscription.Change {

          public static let update = parenthesize <| PartialIso(
            apply: Route.Account.Subscription.Change.update,
            unapply: {
              guard case let .update(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Admin.EpisodeCredit
        ), B == Route.Admin {

          public static let episodeCredits = parenthesize <| PartialIso(
            apply: Route.Admin.episodeCredits,
            unapply: {
              guard case let .episodeCredits(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Admin.FreeEpisodeEmail
        ), B == Route.Admin {

          public static let freeEpisodeEmail = parenthesize <| PartialIso(
            apply: Route.Admin.freeEpisodeEmail,
            unapply: {
              guard case let .freeEpisodeEmail(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Admin {
        public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Admin>(
          apply: const(.some(.index)),
          unapply: {
            guard case .index = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Route.Admin.NewBlogPostEmail
        ), B == Route.Admin {

          public static let newBlogPostEmail = parenthesize <| PartialIso(
            apply: Route.Admin.newBlogPostEmail,
            unapply: {
              guard case let .newBlogPostEmail(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Admin.NewEpisodeEmail
        ), B == Route.Admin {

          public static let newEpisodeEmail = parenthesize <| PartialIso(
            apply: Route.Admin.newEpisodeEmail,
            unapply: {
              guard case let .newEpisodeEmail(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Database.User.Id?
          , 
            Int?
        ), B == Route.Admin.EpisodeCredit {

          public static let add = parenthesize <| PartialIso(
            apply: Route.Admin.EpisodeCredit.add,
            unapply: {
              guard case let .add(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Admin.EpisodeCredit {
        public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Admin.EpisodeCredit>(
          apply: const(.some(.show)),
          unapply: {
            guard case .show = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Episode.Id
        ), B == Route.Admin.FreeEpisodeEmail {

          public static let send = parenthesize <| PartialIso(
            apply: Route.Admin.FreeEpisodeEmail.send,
            unapply: {
              guard case let .send(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Admin.FreeEpisodeEmail {
        public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Admin.FreeEpisodeEmail>(
          apply: const(.some(.index)),
          unapply: {
            guard case .index = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            BlogPost
          , 
            String?
          , 
            String?
          , 
            Bool?
        ), B == Route.Admin.NewBlogPostEmail {

          public static let send = parenthesize <| PartialIso(
            apply: Route.Admin.NewBlogPostEmail.send,
            unapply: {
              guard case let .send(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Admin.NewBlogPostEmail {
        public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Admin.NewBlogPostEmail>(
          apply: const(.some(.index)),
          unapply: {
            guard case .index = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Episode.Id
          , 
            String?
          , 
            String?
          , 
            Bool?
        ), B == Route.Admin.NewEpisodeEmail {

          public static let send = parenthesize <| PartialIso(
            apply: Route.Admin.NewEpisodeEmail.send,
            unapply: {
              guard case let .send(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Admin.NewEpisodeEmail {
        public static let show = parenthesize <| PartialIso<Prelude.Unit, Route.Admin.NewEpisodeEmail>(
          apply: const(.some(.show)),
          unapply: {
            guard case .show = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Route.Feed
        ), B == Route.Blog {

          public static let feed = parenthesize <| PartialIso(
            apply: Route.Blog.feed,
            unapply: {
              guard case let .feed(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Blog {
        public static let index = parenthesize <| PartialIso<Prelude.Unit, Route.Blog>(
          apply: const(.some(.index)),
          unapply: {
            guard case .index = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            BlogPost
        ), B == Route.Blog {

          public static let show = parenthesize <| PartialIso(
            apply: Route.Blog.show,
            unapply: {
              guard case let .show(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Feed {
        public static let atom = parenthesize <| PartialIso<Prelude.Unit, Route.Feed>(
          apply: const(.some(.atom)),
          unapply: {
            guard case .atom = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Database.TeamInvite.Id
        ), B == Route.Invite {

          public static let accept = parenthesize <| PartialIso(
            apply: Route.Invite.accept,
            unapply: {
              guard case let .accept(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Database.TeamInvite.Id
        ), B == Route.Invite {

          public static let resend = parenthesize <| PartialIso(
            apply: Route.Invite.resend,
            unapply: {
              guard case let .resend(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Database.TeamInvite.Id
        ), B == Route.Invite {

          public static let revoke = parenthesize <| PartialIso(
            apply: Route.Invite.revoke,
            unapply: {
              guard case let .revoke(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            EmailAddress?
        ), B == Route.Invite {

          public static let send = parenthesize <| PartialIso(
            apply: Route.Invite.send,
            unapply: {
              guard case let .send(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Database.TeamInvite.Id
        ), B == Route.Invite {

          public static let show = parenthesize <| PartialIso(
            apply: Route.Invite.show,
            unapply: {
              guard case let .show(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Team {
        public static let leave = parenthesize <| PartialIso<Prelude.Unit, Route.Team>(
          apply: const(.some(.leave)),
          unapply: {
            guard case .leave = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            Database.User.Id
        ), B == Route.Team {

          public static let remove = parenthesize <| PartialIso(
            apply: Route.Team.remove,
            unapply: {
              guard case let .remove(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            Route.Webhooks.Stripe
        ), B == Route.Webhooks {

          public static let stripe = parenthesize <| PartialIso(
            apply: Route.Webhooks.stripe,
            unapply: {
              guard case let .stripe(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            PointFree.Stripe.Event<PointFree.Stripe.Invoice>
        ), B == Route.Webhooks.Stripe {

          public static let invoice = parenthesize <| PartialIso(
            apply: Route.Webhooks.Stripe.invoice,
            unapply: {
              guard case let .invoice(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == Route.Webhooks.Stripe {
        public static let `fallthrough` = parenthesize <| PartialIso<Prelude.Unit, Route.Webhooks.Stripe>(
          apply: const(.some(.`fallthrough`)),
          unapply: {
            guard case .`fallthrough` = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == TwitterRoute {
        public static let mbrandonw = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
          apply: const(.some(.mbrandonw)),
          unapply: {
            guard case .mbrandonw = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == TwitterRoute {
        public static let pointfreeco = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
          apply: const(.some(.pointfreeco)),
          unapply: {
            guard case .pointfreeco = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == TwitterRoute {
        public static let stephencelis = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
          apply: const(.some(.stephencelis)),
          unapply: {
            guard case .stephencelis = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }

