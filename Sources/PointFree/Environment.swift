import Css
import Foundation
import Html

public var Current = Environment()

public struct Environment {
  public private(set) var assets = Assets()
  public private(set) var blogPosts = allBlogPosts
  public private(set) var cookieTransform = CookieTransform.encrypted
  public private(set) var database = Database.live
  public private(set) var date: () -> Date = Date.init
  public private(set) var envVars = EnvVars()
  public private(set) var episodes = { [Episode]() }
  public private(set) var features = [Feature].allFeatures
  public private(set) var gitHub = GitHub.live
  public private(set) var logger = Logger()
  public private(set) var mailgun = Mailgun.live
  public private(set) var renderHtml: ([Node]) -> String = Html.render
  public private(set) var stripe = Stripe.live
  public private(set) var uuid: () -> UUID = UUID.init
}
