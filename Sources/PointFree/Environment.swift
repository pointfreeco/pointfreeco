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

// NB: Deprecate remove soon: @available(*, deprecated)
public var Current: DependencyValues {
  DependencyValues._current
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
      @Dependency(\.date.now) var now
      @Dependency(\.envVars.appEnv) var appEnv
      return Episode.all
        .filter {
          appEnv == .production
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
    @Dependency(\.envVars) var envVars
    @Dependency(\.mainEventLoopGroup) var mainEventLoopGroup

    guard !envVars.emergencyMode
    else { return .noop }

    var config = PostgresConfiguration(url: envVars.postgres.databaseUrl.rawValue)!
    if envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com") {
      config.tlsConfiguration?.certificateVerification = .none
    }

    return .live(
      pool: EventLoopGroupConnectionPool(
        source: PostgresConnectionSource(configuration: config),
        on: mainEventLoopGroup
      )
    )
  }
}

extension GitHub.Client: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars
    @Dependency(\.logger) var logger

    return Self(
      clientId: envVars.gitHub.clientId,
      clientSecret: envVars.gitHub.clientSecret,
      logger: logger
    )
  }
}

extension Mailgun.Client: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars
    @Dependency(\.logger) var logger

    return Self(
      apiKey: DependencyValues._current.envVars.mailgun.apiKey,
      appSecret: DependencyValues._current.envVars.appSecret,
      domain: DependencyValues._current.envVars.mailgun.domain,
      logger: DependencyValues._current.logger
    )
  }
}

extension Stripe.Client: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars
    @Dependency(\.logger) var logger

    return Self(
      logger: DependencyValues._current.logger,
      secretKey: DependencyValues._current.envVars.stripe.secretKey
    )
  }
}

extension PointFreeRouter: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars

    return PointFreeRouter(baseURL: DependencyValues._current.envVars.baseUrl)
  }
}
