import Database
import Foundation
import GitHub
import Html
import Mailgun
import Models
import NIO
import Logger
import Prelude
import Stripe

public var Current = Environment()

public struct Environment {
  public var assets = Assets()
  public var blogPosts = allBlogPosts
  public var cookieTransform = CookieTransform.encrypted
  public var database: Database.Client!
  public var date: () -> Date = Date.init
  public var envVars = EnvVars()
  public var episodes = { [Episode]() }
  public var eventLoopGroup: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
  public var features = [Feature].allFeatures
  public var gitHub: GitHub.Client!
  public var logger = Logger()
  public var mailgun: Mailgun.Client!
  public var renderHtml: ([Node]) -> String = Html.render
  public var stripe: Stripe.Client!
  public var uuid: () -> UUID = UUID.init
}
