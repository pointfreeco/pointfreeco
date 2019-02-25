import Css
import Foundation
import GitHub
import Html
import Models
import Logger
import Prelude
import Stripe

public var Current = Environment()

public struct Environment {
  public var assets = Assets()
  public var blogPosts = allBlogPosts
  public var cookieTransform = CookieTransform.encrypted
  public var database = Database.live
  public var date: () -> Date = Date.init
  public var envVars = EnvVars()
  public var episodes = { [Episode]() }
  public var features = [Feature].allFeatures
  public var gitHub = GitHub.Client(clientId: "", clientSecret: "")
  public var logger = Logger()
  public var mailgun = Mailgun.live
  public var renderHtml: ([Node]) -> String = Html.render
  public var stripe = Stripe.Client(secretKey: "", logger: nil)
  public var uuid: () -> UUID = UUID.init
}
