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
      if #available(OSX 10.13, *) {
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
      if #available(OSX 10.13, *) {
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
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
        if #available(OSX 10.13, *) {
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
        if #available(OSX 10.13, *) {
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
      if #available(OSX 10.13, *) {
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

    let freeEpisode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ false

    let env: (Environment) -> Environment =
      (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([freeEpisode]))
        <> (\.database.fetchEpisodeCredits .~ const(pure([.mock])))

    AppEnvironment.with(env) {
      let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)

      let conn = connection(from: episode)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
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

    let freeEpisode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ true

    let env: (Environment) -> Environment =
      (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([freeEpisode]))
        <> (\.database.fetchEpisodeCredits .~ const(pure([.mock])))

    AppEnvironment.with(env) {
      let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)

      let conn = connection(from: episode)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
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

    let freeEpisode = AppEnvironment.current.episodes().first!
      |> \.subscriberOnly .~ true

    let env: (Environment) -> Environment =
      (\.database.fetchUserById .~ const(pure(.some(user))))
        <> (\.episodes .~ unzurry([freeEpisode]))
        <> (\.database.fetchEpisodeCredits .~ const(pure([])))

    AppEnvironment.with(env) {
      let episode = request(to: .episode(.left(AppEnvironment.current.episodes().first!.slug)), session: .loggedIn)

      let conn = connection(from: episode)
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1800))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 500
          assertSnapshot(matching: webView, named: "mobile")
        }
      #endif
    }
  }
}
