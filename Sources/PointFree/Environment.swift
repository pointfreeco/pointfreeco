import Database
import Foundation
import GitHub
import Html
import Logging
import Mailgun
import Models
import Prelude
import Stripe

public var Current = Environment()

public struct Environment {
  public var assets = Assets()
  public var blogPosts = allBlogPosts
  public var calendar = Calendar.autoupdatingCurrent
  public var cookieTransform = CookieTransform.encrypted
  public var collections = Episode.Collection.all
  public var database: Database.Client!
  public var date: () -> Date = Date.init
  public var envVars = EnvVars()
  public var episodes: () -> [Episode]
  public var features = Feature.allFeatures
  public var gitHub: GitHub.Client!
  public var logger = Logger(label: "co.pointfree")
  public var mailgun: Mailgun.Client!
  public var renderHtml: (Node) -> String = { Html.render($0) }
  public var renderXml: (Node) -> String = Html._xmlRender
  public var stripe: Stripe.Client!
  public var uuid: () -> UUID = UUID.init

  public init(
    assets: Assets = Assets(),
    blogPosts: @escaping () -> [BlogPost] = allBlogPosts,
    calendar: Calendar = .autoupdatingCurrent,
    cookieTransform: CookieTransform = .encrypted,
    collections: [Episode.Collection] = Episode.Collection.all,
    database: Database.Client? = nil,
    date: @escaping () -> Date = Date.init,
    envVars: EnvVars = EnvVars(),
    episodes: @escaping () -> [Episode] = { [Episode]() },
    features: [Feature] = Feature.allFeatures,
    gitHub: GitHub.Client? = nil,
    logger: Logger = Logger(label: "co.pointfree"),
    mailgun: Mailgun.Client? = nil,
    renderHtml: @escaping (Node) -> String = { Html.render($0) },
    renderXml: @escaping (Node) -> String = Html._xmlRender,
    stripe: Stripe.Client? = nil,
    uuid: @escaping () -> UUID = UUID.init
  ) {
    self.assets = assets
    self.blogPosts = blogPosts
    self.calendar = calendar
    self.cookieTransform = cookieTransform
    self.collections = collections
    self.database = database
    self.date = date
    self.envVars = envVars
    self.episodes = episodes
    self.features = features
    self.gitHub = gitHub
    self.logger = logger
    self.mailgun = mailgun
    self.renderHtml = renderHtml
    self.renderXml = renderXml
    self.stripe = stripe
    self.uuid = uuid
  }
}
