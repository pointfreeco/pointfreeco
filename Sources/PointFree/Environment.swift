import Database
import Dependencies
import Foundation
import GitHub
import Html
import Logging
import Mailgun
import Models
import NIODependencies
import PointFreeRouter
import PostgresKit
import Prelude
import Stripe
import Transcripts
import VimeoClient
import PrivateTranscripts

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

extension MainEventLoopGroupKey: DependencyKey {
  public static var liveValue: any EventLoopGroup {
    #if DEBUG
      return MultiThreadedEventLoopGroup(numberOfThreads: 1)
    #else
      return MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    #endif
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

extension Database.Client: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars
    @Dependency(\.mainEventLoopGroup) var mainEventLoopGroup

    guard !envVars.emergencyMode
    else { return .noop }

    var config = PostgresConfiguration(url: envVars.postgres.databaseUrl.rawValue)!
    if envVars.postgres.databaseUrl.rawValue.contains("amazonaws.com") {
      config.tlsConfiguration = .clientDefault
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

    return Self(
      clientId: envVars.gitHub.clientId,
      clientSecret: envVars.gitHub.clientSecret
    )
  }
}

extension Mailgun.Client: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars

    return Self(
      apiKey: envVars.mailgun.apiKey,
      appSecret: envVars.appSecret,
      domain: envVars.mailgun.domain
    )
  }
}

extension Stripe.Client: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars

    return Self(secretKey: envVars.stripe.secretKey)
  }
}

extension PointFreeRouter: DependencyKey {
  public static var liveValue: Self {
    @Dependency(\.envVars) var envVars

    return PointFreeRouter(baseURL: envVars.baseUrl)
  }
}

extension VimeoClient: DependencyKey {
  public static var liveValue: VimeoClient {
    @Dependency(\.envVars) var envVars
    return .live(bearer: envVars.vimeoBearer)
  }
}
