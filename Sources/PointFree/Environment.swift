import Database
import Dependencies
import Foundation
import GitHub
import Html
import Logging
import Mailgun
import Models
import PointFreeRouter
import PostgresKit
import Prelude
import Stripe 

public let Current = Environment()

public struct Environment {
  @Dependency(\.assets) public var assets
  @Dependency(\.blogPosts) public var blogPosts
  @Dependency(\.calendar) public var calendar
  @Dependency(\.cookieTransform) public var cookieTransform
  @Dependency(\.collections) public var collections
  @Dependency(\.database) public var database
  @Dependency(\.date) public var date
  @Dependency(\.envVars) public var envVars
  @Dependency(\.episodes) public var episodes
  @Dependency(\.features) public var features
  @Dependency(\.gitHub) public var gitHub
  @Dependency(\.logger) public var logger
  @Dependency(\.mailgun) public var mailgun
  @Dependency(\.renderHtml) public var renderHtml
  @Dependency(\.renderXml) public var renderXml
  @Dependency(\.stripe) public var stripe
  @Dependency(\.uuid) public var uuid

  public init() {}
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

extension BlogPost: DependencyKey {
  public static let liveValue: () -> [BlogPost] = allBlogPosts
}

extension Episode: DependencyKey {
  public static var liveValue: () -> [Episode] {
#if !OSS
    Episode.bootstrapPrivateEpisodes()
#endif
    assert(Episode.all.count == Set(Episode.all.map(\.id)).count)
    assert(Episode.all.count == Set(Episode.all.map(\.sequence)).count)

    return {
      let now = Current.date()
      return Episode.all
        .filter {
          Current.envVars.appEnv == .production
          ? $0.publishedAt <= now
          : true
        }
        .sorted(by: their(\.sequence))
    }
  }
}

private enum RenderHTML: DependencyKey {
  static let liveValue: (Node) -> String = { Html.render($0) }
  static let testValue: (Node) -> String = { debugRender($0) }
}

extension DependencyValues {
  public var renderHtml: (Node) -> String {
    get { self[RenderHTML.self] }
    set { self[RenderHTML.self] = newValue }
  }
}

private enum RenderXML: DependencyKey {
  static let liveValue: (Node) -> String = { Html._xmlRender($0) }
  static let testValue: (Node) -> String = { _debugXmlRender($0) }
}

extension DependencyValues {
  public var renderXml: (Node) -> String {
    get { self[RenderXML.self] }
    set { self[RenderXML.self] = newValue }
  }
}

private enum MainEventLoopGroupKey: DependencyKey {
  static var liveValue: MultiThreadedEventLoopGroup {
#if DEBUG
    let numberOfThreads = 1
#else
    let numberOfThreads = System.coreCount
#endif
    return MultiThreadedEventLoopGroup(numberOfThreads: numberOfThreads)
  }
}

extension DependencyValues {
  public var mainEventLoopGroup: MultiThreadedEventLoopGroup {
    get { self[MainEventLoopGroupKey.self] }
    set { self[MainEventLoopGroupKey.self] = newValue }
  }
}

extension Database.Client: DependencyKey {
  public static var liveValue: Self {
    guard !DependencyValues._current.envVars.emergencyMode
    else { return .noop }

    var config = PostgresConfiguration(
      url: DependencyValues._current.envVars.postgres.databaseUrl.rawValue
    )!
    if DependencyValues._current.envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com") {
      config.tlsConfiguration?.certificateVerification = .none
    }

    return .live(
      pool: EventLoopGroupConnectionPool(
        source: PostgresConnectionSource(configuration: config),
        on: DependencyValues._current.mainEventLoopGroup
      )
    )
  }
}

extension GitHub.Client: DependencyKey {
  public static var liveValue: Self {
    Self(
      clientId: DependencyValues._current.envVars.gitHub.clientId,
      clientSecret: DependencyValues._current.envVars.gitHub.clientSecret,
      logger: DependencyValues._current.logger
    )
  }
}

extension Mailgun.Client: DependencyKey {
  public static var liveValue: Self {
    Self(
      apiKey: DependencyValues._current.envVars.mailgun.apiKey,
      appSecret: DependencyValues._current.envVars.appSecret,
      domain: DependencyValues._current.envVars.mailgun.domain,
      logger: DependencyValues._current.logger
    )
  }
}

extension Stripe.Client: DependencyKey {
  public static var liveValue: Self {
    Self(
      logger: DependencyValues._current.logger,
      secretKey: DependencyValues._current.envVars.stripe.secretKey
    )
  }
}

extension PointFreeRouter: DependencyKey {
  public static var liveValue: Self {
    PointFreeRouter(baseURL: DependencyValues._current.envVars.baseUrl)
  }
}
