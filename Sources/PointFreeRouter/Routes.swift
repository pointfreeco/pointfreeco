import ApplicativeRouter
import Either
import Models
import PointFreePrelude
import Prelude
import Stripe

public enum Route: DerivePartialIsos, Equatable {
  case about
  case account(PointFreeRouter.Account)
  case admin(PointFreeRouter.Admin)
  case appleDeveloperMerchantIdDomainAssociation
  case blog(Blog)
  case discounts(code: Stripe.Coupon.Id)
  case episode(Either<String, Int>)
  case episodes
  case expressUnsubscribe(userId: User.Id, newsletter: EmailSetting.Newsletter)
  case expressUnsubscribeReply(MailgunForwardPayload)
  case feed(Feed)
  case gitHubCallback(code: String?, redirect: String?)
  case invite(Invite)
  case login(redirect: String?)
  case logout
  case pricing(Pricing?, expand: Bool?)
  case privacy
  case home
  case subscribe(SubscribeData?)
  case team(Team)
  case useEpisodeCredit(Episode.Id)
  case webhooks(Webhooks)

  public enum Blog: DerivePartialIsos, Equatable {
    case feed
    case index
    // TODO: strengthen Int to BlogPost.Id
    case show(Either<String, Int>)
  }

  public enum Feed: DerivePartialIsos, Equatable {
    case atom
    case episodes
  }

  public enum Invite: DerivePartialIsos, Equatable {
    case accept(TeamInvite.Id)
    case resend(TeamInvite.Id)
    case revoke(TeamInvite.Id)
    case send(EmailAddress?)
    case show(TeamInvite.Id)
  }

  public enum Team: DerivePartialIsos, Equatable {
    case leave
    case remove(User.Id)
  }

  public enum Webhooks: DerivePartialIsos, Equatable {
    // TODO: what to do about this _
    case stripe(_Stripe)

    public enum _Stripe: DerivePartialIsos, Equatable {
      case event(Event<Either<Invoice, Stripe.Subscription>>)
      case `fallthrough`
    }
  }
}

public func pointFreeRouter(appSecret: String, mailgunApiKey: String) -> Router<Route> {
  return routers(appSecret: appSecret, mailgunApiKey: mailgunApiKey).reduce(.empty, <|>)
}

private func routers(appSecret: String, mailgunApiKey: String) -> [Router<Route>] {
  return [
    .about
      <¢> get %> lit("about") <% end,

    .account
      <¢> lit("account") %> accountRouter(appSecret: appSecret),

    .admin
      <¢> lit("admin") %> adminRouter,

    .appleDeveloperMerchantIdDomainAssociation
      <¢> get %> lit(".well-known") %> lit("apple-developer-merchantid-domain-association"),

    .blog <<< .feed
      <¢> get %> lit("blog") %> lit("feed") %> lit("atom.xml") <% end,

    .discounts
      <¢> get %> lit("discounts") %> pathParam(.string >>> .tagged) <% end,

    .blog <<< .index
      <¢> get %> lit("blog") <% end,

    .blog <<< .show
      <¢> get %> lit("blog") %> lit("posts") %> pathParam(.intOrString) <% end,

    .episode
      <¢> get %> lit("episodes") %> pathParam(.intOrString) <% end,

    .episodes
      <¢> get %> lit("episodes") <% end,

    .feed <<< .atom
      <¢> get %> lit("feed") %> lit("atom.xml") <% end,

    .feed <<< .episodes
      <¢> (get <|> head) %> lit("feed") %> lit("episodes.xml") <% end,

    .expressUnsubscribe
      <¢> get %> lit("newsletters") %> lit("express-unsubscribe")
      %> queryParam("payload", .decrypted(withSecret: appSecret) >>> payload(.uuid >>> .tagged, .rawRepresentable))
      <% end,

    .expressUnsubscribeReply
      <¢> post %> lit("newsletters") %> lit("express-unsubscribe-reply")
      %> formBody(MailgunForwardPayload.self, decoder: formDecoder).map(.signatureVerification(apiKey: mailgunApiKey))
      <% end,

    .gitHubCallback
      <¢> get %> lit("github-auth")
      %> queryParam("code", opt(.string)) <%> queryParam("redirect", opt(.string))
      <% end,

    .home
      <¢> get <% end,

    .invite <<< .accept
      <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("accept") <% end,

    .invite <<< .resend
      <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("resend") <% end,

    .invite <<< .revoke
      <¢> post %> lit("invites") %> pathParam(.uuid >>> .tagged) <% lit("revoke") <% end,

    .invite <<< .send
      // TODO: this weird Optional.iso.some is cause `formField` takes a partial iso `String -> A` instead of
      //       `(String?) -> A` like it is for `queryParam`.
      <¢> post %> lit("invites") %> formField("email", Optional.iso.some >>> opt(.rawRepresentable)) <% end,

    .invite <<< .show
      <¢> get %> lit("invites") %> pathParam(.uuid >>> .tagged) <% end,

    .login
      <¢> get %> lit("login") %> queryParam("redirect", opt(.string)) <% end,

    .logout
      <¢> get %> lit("logout") <% end,

    .pricing
      <¢> get %> lit("pricing")
      %> (queryParam("plan", opt(.string)) <%> queryParam("quantity", opt(.int)))
        .map(PartialIso.pricing >>> Optional.iso.some)
      <%> queryParam("expand", opt(.bool))
      <% end,

    .privacy
      <¢> get %> lit("privacy") <% end,

    .subscribe
      <¢> post %> lit("subscribe") %> formBody(SubscribeData?.self, decoder: formDecoder) <% end,

    .team <<< .leave
      <¢> post %> lit("account") %> lit("team") %> lit("leave")
      <% end,

    .team <<< .remove
      <¢> post %> lit("account") %> lit("team") %> lit("members")
      %> pathParam(.uuid >>> .tagged)
      <% lit("remove")
      <% end,

    .useEpisodeCredit
      <¢> post %> lit("episodes") %> pathParam(.int >>> .tagged) <% lit("credit") <% end,

    .webhooks <<< .stripe <<< .event
      <¢> post %> lit("webhooks") %> lit("stripe")
      %> jsonBody(
        Stripe.Event<Either<Stripe.Invoice, Stripe.Subscription>>.self,
        encoder: Stripe.jsonEncoder,
        decoder: Stripe.jsonDecoder
      )
      <% end,

    .webhooks <<< .stripe <<< .fallthrough
      <¢> post %> lit("webhooks") %> lit("stripe") <% end,
    ]
}
