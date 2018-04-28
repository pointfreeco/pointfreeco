import Either
import Foundation
import Optics
import Prelude

public struct Assets {
  public var brandonImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/about-us/brando.jpg"
  public var stephenImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/about-us/stephen.jpg"
  public var emailHeaderImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-email-header.png"
  public var pointersEmailHeaderImgSrc = "https://d3rccdn33rt8ze.cloudfront.net/email-assets/pf-pointers-header.jpg"
}

public enum CookieTransform: String, Codable {
  case plaintext
  case encrypted
}

public var Current = Environment()

public struct Environment {
  public private(set) var assets: Assets
  public private(set) var blogPosts: () -> [BlogPost]
  public private(set) var cookieTransform: CookieTransform
  public private(set) var database: Database
  public private(set) var date: () -> Date
  public private(set) var envVars: EnvVars
  public private(set) var episodes: () -> [Episode]
  public private(set) var features: [Feature]
  public private(set) var gitHub: GitHub
  public private(set) var logger: Logger
  public private(set) var mailgun: Mailgun
  public private(set) var stripe: Stripe

  init(
    assets: Assets = .init(),
    blogPosts: @escaping () -> [BlogPost] = allBlogPosts,
    cookieTransform: CookieTransform = .encrypted,
    database: PointFree.Database = .live,
    date: @escaping () -> Date = Date.init,
    envVars: EnvVars = EnvVars(),
    episodes: @escaping () -> [Episode] = { [typeSafeHtml, typeSafeHtml, typeSafeHtml] },
    features: [Feature] = Feature.allFeatures,
    gitHub: GitHub = .live,
    logger: Logger = Logger(),
    mailgun: Mailgun = .live,
    stripe: Stripe = .live) {

    self.assets = assets
    self.blogPosts = blogPosts
    self.cookieTransform = cookieTransform
    self.database = database
    self.date = date
    self.envVars = envVars
    self.episodes = episodes
    self.features = features
    self.gitHub = gitHub
    self.logger = logger
    self.mailgun = mailgun
    self.stripe = stripe
  }

  public mutating func make(_ changes: ((Environment) -> Environment)...) {
    self = self |> concat(changes)
  }
}
