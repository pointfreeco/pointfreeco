import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
import WebKit
#endif

class EpisodeTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }

  func testEpisodePage() {
    let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedOut)

    let conn = connection(from: episode)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testEpisodePageSubscriber() {
    let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)

    let conn = connection(from: episode)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 2200))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView, named: "desktop")

      webView.frame.size.width = 500
      assertSnapshot(matching: webView, named: "mobile")
    }
    #endif
  }

  func testFreeEpisodePage() {
    let freeEpisode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ false

    AppEnvironment.with(\.episodes .~ { [freeEpisode] }) {
      let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedOut)

      let conn = connection(from: episode)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testFreeEpisodePageSubscriber() {
    let freeEpisode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ false

    AppEnvironment.with(\.episodes .~ { [freeEpisode] }) {
      let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)

      let conn = connection(from: episode)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testEpisodeNotFound() {
    let episode = request(to: .episode(.left("object-oriented-programming")))

    let conn = connection(from: episode)
    let result = conn |> siteMiddleware

    assertSnapshot(matching: result.perform())

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1000))
      webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
      assertSnapshot(matching: webView)
    }
    #endif
  }

  func testEpisodeCredit_PublicEpisode_NonSubscriber_UsedCredit() {
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ false

    let env: (Environment) -> Environment =
      (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([episode]))
        <> (\.database.fetchEpisodeCredits .~ const(pure([.mock])))
        <> ((\Environment.database.fetchSubscriptionByOwnerId) .~ const(pure(nil)))

    AppEnvironment.with(env) {
      let conn = connection(
        from: request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_UsedCredit() {
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ true

    let env: (Environment) -> Environment =
      (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([episode]))
        <> (\.database.fetchEpisodeCredits .~ const(pure([.mock])))
        <> ((\Environment.database.fetchSubscriptionByOwnerId) .~ const(pure(nil)))

    AppEnvironment.with(env) {
      let conn = connection(
        from: request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_HasCredits() {
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ true

    let env: (Environment) -> Environment =
      (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([episode]))
        <> (\.database.fetchEpisodeCredits .~ const(pure([])))
        <> ((\Environment.database.fetchSubscriptionByOwnerId) .~ const(pure(nil)))

    AppEnvironment.with(env) {
      let conn = connection(
        from: request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
      if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
        webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
        assertSnapshot(matching: webView, named: "desktop")

        webView.frame.size.width = 500
        assertSnapshot(matching: webView, named: "mobile")
      }
      #endif
    }
  }

  func testRedeemEpisodeCredit_HappyPath() {
    let episode = Episode.mock
      |> \.subscriberOnly .~ true

    let env: (Environment) -> Environment =
      (\.database .~ .live)
        <> (\.episodes .~ unzurry([episode]))

    AppEnvironment.with(env) {
      let user = AppEnvironment.current.database
        .registerUser(.mock, "hello@pointfree.co")
        .run.perform().right!!
      _ = AppEnvironment.current.database.updateUser(user.id, nil, nil, nil, 1).run.perform()

      let credit = Database.EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      XCTAssertEqual(
        [credit],
        AppEnvironment.current.database.fetchEpisodeCredits(user.id).run.perform().right!
      )
      XCTAssertEqual(
        0,
        AppEnvironment.current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
      )
    }
  }

  func testRedeemEpisodeCredit_NotEnoughCredits() {
    let episode = Episode.mock
      |> \.subscriberOnly .~ true

    let user = Database.User.mock
      |> \.episodeCreditCount .~ 0
      |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    let env: (Environment) -> Environment =
      (\.database .~ .live)
        <> (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([episode]))

    AppEnvironment.with(env) {
      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      XCTAssertEqual(
        [],
        AppEnvironment.current.database.fetchEpisodeCredits(user.id).run.perform().right!
      )
      XCTAssertEqual(
        0,
        AppEnvironment.current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
      )
    }
  }

  func testRedeemEpisodeCredit_PublicEpisode() {
    let episode = Episode.mock
      |> \.subscriberOnly .~ false

    let user = Database.User.mock
      |> \.episodeCreditCount .~ 1
      |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    let env: (Environment) -> Environment =
      (\.database .~ .live)
        <> (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([episode]))

    AppEnvironment.with(env) {
      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      XCTAssertEqual(
        [],
        AppEnvironment.current.database.fetchEpisodeCredits(user.id).run.perform().right!
      )
      XCTAssertEqual(
        1,
        AppEnvironment.current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
      )
    }
  }

  func testRedeemEpisodeCredit_AlreadyCredited() {
    let episode = Episode.mock
      |> \.subscriberOnly .~ false

    let env: (Environment) -> Environment =
      (\.database .~ .live)
        <> (\.episodes .~ unzurry([episode]))

    AppEnvironment.with(env) {
      let user = AppEnvironment.current.database
        .registerUser(.mock, "hello@pointfree.co")
        .run.perform().right!!
      _ = AppEnvironment.current.database.updateUser(user.id, nil, nil, nil, 1).run.perform()
      _ = AppEnvironment.current.database.redeemEpisodeCredit(episode.sequence, user.id).run.perform()

      let credit = Database.EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      XCTAssertEqual(
        [credit],
        AppEnvironment.current.database.fetchEpisodeCredits(user.id).run.perform().right!
      )
      XCTAssertEqual(
        1,
        AppEnvironment.current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
      )
    }
  }
}
