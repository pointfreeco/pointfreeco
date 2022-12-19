import Database
import Dependencies
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
  @Dependency(\.calendar) public var calendar
  @Dependency(\.cookieTransform) public var cookieTransform
  public var collections = Episode.Collection.all
  public var database: Database.Client!
  @Dependency(\.date) public var date
  @Dependency(\.envVars) public var envVars
  public var episodes: () -> [Episode]
  public var features = Feature.allFeatures
  public var gitHub: GitHub.Client!
  @Dependency(\.logger) public var logger
  public var mailgun: Mailgun.Client!
  public var renderHtml: (Node) -> String = { Html.render($0) }
  public var renderXml: (Node) -> String = Html._xmlRender
  public var stripe: Stripe.Client!
  @Dependency(\.uuid) public var uuid

  public init(
    assets: Assets = Assets(),
    blogPosts: @escaping () -> [BlogPost] = allBlogPosts,
    collections: [Episode.Collection] = Episode.Collection.all,
    database: Database.Client? = nil,
    episodes: @escaping () -> [Episode] = { [Episode]() },
    features: [Feature] = Feature.allFeatures,
    gitHub: GitHub.Client? = nil,
    mailgun: Mailgun.Client? = nil,
    renderHtml: @escaping (Node) -> String = { Html.render($0) },
    renderXml: @escaping (Node) -> String = Html._xmlRender,
    stripe: Stripe.Client? = nil
  ) {
    self.assets = assets
    self.blogPosts = blogPosts
    self.collections = collections
    self.database = database
    self.episodes = episodes
    self.features = features
    self.gitHub = gitHub
    self.mailgun = mailgun
    self.renderHtml = renderHtml
    self.renderXml = renderXml
    self.stripe = stripe
  }
}

extension Logger: DependencyKey {
  public static let liveValue = Logger(label: "co.pointfree")
  public static let testValue = Logger(label: "co.pointfree.PointFreeTestSupport")
}

extension DependencyValues {
  public var logger: Logger {
    get { self[Logger.self] }
    set { self[Logger.self] = newValue }
  }
}
