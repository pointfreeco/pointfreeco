import Dependencies
import Either
import Foundation
import Html
import HttpPipeline
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe
import Syndication
import Tuple

func accountRssMiddleware(
  _ conn: Conn<StatusLineOpen, User.RssSalt>
) async -> Conn<ResponseEnded, Data> {
  do {
    guard let user = try? await Current.database.fetchUserByRssSalt(conn.data)
    else {
      return conn.invalidatedFeedResponse(errorMessage: suspiciousError)
    }

    // Track feed request
    await notifyError(subject: "Create Feed Request Event Failed") {
      try await Current.database.createFeedRequestEvent(
        .privateEpisodesFeed,
        conn.request.allHTTPHeaderFields?["User-Agent"] ?? "",
        user.id
      )
    }

    // Validate user agent
    if let userAgent = conn.request.allHTTPHeaderFields?["User-Agent"]?.lowercased(),
      Current.envVars.rssUserAgentWatchlist.contains(where: { userAgent.contains($0) })
    {
      try await Current.database.updateUser(
        id: user.id,
        rssSalt: User.RssSalt(Current.uuid().uuidString.lowercased())
      )
      _ = try await sendInvalidRssFeedEmail(user: user, userAgent: userAgent)
        .withExcept { $0 as Error }
        .performAsync()
      return conn.invalidatedFeedResponse(errorMessage: suspiciousError)
    }

    // Require active subscription
    let subscription = try await Current.database
      .fetchSubscriptionById(user.subscriptionId.unwrap())
    guard !subscription.deactivated
    else {
      return conn.invalidatedFeedResponse(errorMessage: deactivatedError)
    }
    guard
      SubscriberState(
        user: user,
        subscription: subscription,
        enterpriseAccount: nil
      )
      .isActive
    else {
      return conn.invalidatedFeedResponse(errorMessage: inactiveError)
    }

    // Gracefully degrade when Stripe is unavailable
    let stripeSubscription = try? await Current.stripe
      .fetchSubscription(subscription.stripeSubscriptionId)

    return conn.map { _ in (stripeSubscription, user) }
      .writeStatus(.ok)
      .respond(xml: privateEpisodesFeedView)
  } catch {
    return conn.invalidatedFeedResponse(errorMessage: inactiveError)
  }
}

extension Conn where Step == StatusLineOpen {
  fileprivate func invalidatedFeedResponse(errorMessage: String) -> Conn<ResponseEnded, Data> {
    self
      .map { _ in errorMessage }
      .writeStatus(.ok)
      .respond(xml: invalidatedFeedView)
  }
}

private var deactivatedError: String {
  """
  ‼️ Your subscription has been deactivated. Please contact us at support@pointfree.co to regain \
  access to Point-Free.
  """
}

private var inactiveError: String {
  @Dependency(\.siteRouter) var siteRouter
  return """
    ‼️ The URL for this feed has been turned off by Point-Free as the associated subscription is no \
    longer active. If you would like reactive this feed you can resubscribe to Point-Free on your \
    account page at \(siteRouter.url(for: .account())). If you think this is an error, please \
    contact support@pointfree.co.
    """
}

private var suspiciousError: String {
  @Dependency(\.siteRouter) var siteRouter
  return """
    ‼️ The URL for this feed has been turned off by Point-Free due to suspicious activity. You can \
    retrieve your most up-to-date private podcast URL by visiting your account page at \
    \(siteRouter.url(for: .account())). If you think this is an error, please contact \
    support@pointfree.co.
    """
}

private let privateEpisodesFeedView = itunesRssFeedLayout {
  (data: (subscription: Stripe.Subscription?, user: User)) -> Node in
  node(
    rssChannel: privateRssChannel(user: data.user),
    items: items(forUser: data.user, subscription: data.subscription)
  )
}

func privateRssChannel(user: User) -> RssChannel {
  @Dependency(\.siteRouter) var siteRouter

  let description = """
    Point-Free is a video series about functional programming and the Swift programming language. Each episode
    covers a topic that may seem complex and academic at first, but turns out to be quite simple. At the end of
    each episode we’ll ask “what’s the point?!”, so that we can bring the concepts back down to earth and show
    how these ideas can improve the quality of your code today.

    ---

    This is a private feed associated with the Point-Free account \(user.email). Please do not share this link
    with anyone else.
    """
  let title = "Point-Free Videos (Private feed for \(user.email.rawValue))"

  return RssChannel(
    copyright:
      "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: description,
    image: .init(
      link: siteRouter.url(for: .home),
      title: title,
      url: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
      block: .yes,
      categories: [
        .init(name: "Technology", subcategory: "Software How-To"),
        .init(name: "Education", subcategory: "Training"),
      ],
      explicit: false,
      keywords: [
        "programming",
        "development",
        "mobile",
        "ios",
        "functional",
        "swift",
        "apple",
        "developer",
        "software engineering",
        "server",
        "app",
      ],
      image: .init(
        href: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"),
      owner: .init(email: "support@pointfree.co", name: "Brandon Williams & Stephen Celis"),
      subtitle: "Functional programming concepts explained simply.",
      summary: description,
      type: .episodic
    ),
    language: "en-US",
    link: siteRouter.url(for: .home),
    title: title
  )
}

let nonYearlyMaxRssItems = 4

private func items(forUser user: User, subscription: Stripe.Subscription?) -> [RssItem] {
  Current
    .episodes()
    .filter { $0.sequence != 0 }
    .sorted(by: their(\.sequence, >))
    .prefix(subscription?.plan.interval == .some(.year) ? 99999 : nonYearlyMaxRssItems)
    .map { item(forUser: user, episode: $0) }
}

private func item(forUser user: User, episode: Episode) -> RssItem {
  @Dependency(\.siteRouter) var siteRouter

  return RssItem(
    description: episode.blurb,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: .init(
      length: episode.fullVideo.bytesLength,
      type: "video/mp4",
      url: episode.fullVideo.downloadUrl(.hd720)
    ),
    guid: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: episode.length.rawValue,
      episode: episode.sequence,
      episodeType: .full,
      explicit: false,
      image: episode.image,
      subtitle: episode.blurb,
      summary: episode.blurb,
      season: 1,
      title: episode.fullTitle
    ),
    link: siteRouter.url(for: .episode(.show(.left(episode.slug)))),
    media: .init(
      content: .init(
        length: episode.fullVideo.bytesLength,
        medium: "video",
        type: "video/mp4",
        url: episode.fullVideo.downloadUrl(.hd720)
      ),
      title: episode.fullTitle
    ),
    pubDate: episode.publishedAt,
    title: episode.fullTitle
  )
}

private let invalidatedFeedView = itunesRssFeedLayout { errorMessage in
  node(
    rssChannel: invalidatedChannel(errorMessage: errorMessage),
    items: [invalidatedItem(errorMessage: errorMessage)]
  )
}

private func invalidatedChannel(errorMessage: String) -> RssChannel {
  @Dependency(\.siteRouter) var siteRouter

  return .init(
    copyright:
      "Copyright Point-Free, Inc. \(Calendar.current.component(.year, from: Current.date()))",
    description: errorMessage,
    image: .init(
      link: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg",
      title: "Point-Free",
      url: siteRouter.url(for: .home)
    ),
    itunes: .init(
      author: "Brandon Williams & Stephen Celis",
      block: .yes,
      categories: [
        .init(name: "Technology", subcategory: "Software How-To"),
        .init(name: "Education", subcategory: "Training"),
      ],
      explicit: false,
      keywords: [
        "programming",
        "development",
        "mobile",
        "ios",
        "functional",
        "swift",
        "apple",
        "developer",
        "software engineering",
        "server",
        "app",
      ],
      image: .init(
        href: "https://d3rccdn33rt8ze.cloudfront.net/social-assets/pf-avatar-square.jpg"),
      owner: .init(email: "support@pointfree.co", name: "Brandon Williams & Stephen Celis"),
      subtitle: "Functional programming concepts explained simply.",
      summary: errorMessage,
      type: .episodic
    ),
    language: "en-US",
    link: siteRouter.url(for: .home),
    title: "Point-Free"
  )
}

private func invalidatedItem(errorMessage: String) -> RssItem {
  @Dependency(\.siteRouter) var siteRouter

  let episode = Current.episodes()[0]
  return RssItem(
    description: errorMessage,
    dublinCore: .init(creators: ["Brandon Williams", "Stephen Celis"]),
    enclosure: .init(
      length: episode.fullVideo.bytesLength,
      type: "video/mp4",
      url: episode.fullVideo.downloadUrl(.sd540)
    ),
    guid: String(Current.date().timeIntervalSince1970),
    itunes: RssItem.Itunes(
      author: "Brandon Williams & Stephen Celis",
      duration: 0,
      episode: 1,
      episodeType: .full,
      explicit: false,
      image: episode.image,
      subtitle: errorMessage,
      summary: errorMessage,
      season: 1,
      title: "Invalid Feed URL"
    ),
    link: siteRouter.url(for: .home),
    media: .init(
      content: .init(
        length: episode.fullVideo.bytesLength,
        medium: "video",
        type: "video/mp4",
        url: episode.fullVideo.downloadUrl(.sd540)
      ),
      title: "Invalid Feed URL"
    ),
    pubDate: Date.distantFuture,
    title: "Invalid Feed URL"
  )
}

extension Conn where Step == ResponseEnded, A == Data {
  func clearBodyForHeadRequests() -> Self {
    guard self.request.httpMethod == "HEAD" else { return self }
    var conn = self
    conn.data = Data()
    conn.response.body = Data()
    return conn
  }
}
