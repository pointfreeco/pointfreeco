import Database
import DatabaseTestSupport
import Either
import GitHub
import GitHubTestSupport
import HttpPipeline
import Models
import ModelsTestSupport
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class EpisodePageTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testEpisodePage() {
    update(&Current, \.database .~ .mock)

    let episode = request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedOut)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2400)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2400))
        ]
      )
    }
    #endif
  }

  func testEpisodePageSubscriber() {
    update(&Current, \.database .~ .mock)
    let episode = request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2600)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2600))
        ]
      )
    }
    #endif
  }

  func testFreeEpisodePage() {
    let freeEpisode = Current.episodes()[0]
      |> \.permission .~ .free

    update(
      &Current,
      \.database .~ .mock,
      \.episodes .~ { [freeEpisode] }
    )

    let episode = request(to: .episode(.left(freeEpisode.slug)), session: .loggedOut)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2100)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2100))
        ]
      )
    }
    #endif
  }

  func testFreeEpisodePageSubscriber() {
    let freeEpisode = Current.episodes()[0]
      |> \.permission .~ .free

    update(
      &Current,
      \.database .~ .mock,
      \.episodes .~ { [freeEpisode] }
    )

    let episode = request(to: .episode(.left(freeEpisode.slug)), session: .loggedIn)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2100)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2100))
        ]
      )
    }
    #endif
  }

  func testEpisodeNotFound() {
    update(&Current, \.database .~ .mock)

    let episode = request(to: .episode(.left("object-oriented-programming")))

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshot(
        matching: conn |> siteMiddleware,
        as: .ioConnWebView(size: .init(width: 1100, height: 1000))
      )
    }
    #endif
  }

  func testEpisodeCredit_PublicEpisode_NonSubscriber_UsedCredit() {
    let user = Models.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = Current.episodes()[1]
      |> \.permission .~ .free

    update(
      &Current,
      (\Environment.database) .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode]),
      \.database.fetchEpisodeCredits .~ const(pure([.mock])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .episode(.left(episode.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 1800))
        ]
      )
    }
    #endif
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_UsedCredit() {
    let user = Models.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = Current.episodes()[1]
      |> \.permission .~ .subscriberOnly

    update(
      &Current,
      (\Environment.database) .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode]),
      \.database.fetchEpisodeCredits .~ const(pure([.mock])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 1800)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 1800))
        ]
      )
    }
    #endif
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_HasCredits() {
    let user = Models.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = Current.episodes().first!
      |> \.permission .~ .subscriberOnly

    update(
      &Current,
      (\Environment.database) .~ .mock,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode]),
      \.database.fetchEpisodeCredits .~ const(pure([])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2100)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2100))
        ]
      )
    }
    #endif
  }

  func testRedeemEpisodeCredit_HappyPath() {
    let episode = Episode.mock
      |> \.permission .~ .subscriberOnly

    update(
      &Current,
      \.episodes .~ unzurry([episode])
    )

    let user = Current.database
      .registerUser(.mock, "hello@pointfree.co")
      .run.perform().right!!
    _ = Current.database.updateUser(user.id, nil, nil, nil, 1, nil).run.perform()

    let credit = EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

    let conn = connection(
      from: request(
        to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(
      [credit],
      Current.database.fetchEpisodeCredits(user.id).run.perform().right!
    )
    XCTAssertEqual(
      0,
      Current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
    )
  }

  func testRedeemEpisodeCredit_NotEnoughCredits() {
    let episode = Episode.mock
      |> \.permission .~ .subscriberOnly

    let user = User.mock
      |> \.episodeCreditCount .~ 0
      |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode])
    )

    let conn = connection(
      from: request(
        to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(
      [],
      Current.database.fetchEpisodeCredits(user.id).run.perform().right!
    )
    XCTAssertEqual(
      0,
      Current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
    )
  }

  func testRedeemEpisodeCredit_PublicEpisode() {
    let episode = Episode.mock
      |> \.permission .~ .free

    let user = User.mock
      |> \.episodeCreditCount .~ 1
      |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    update(
      &Current,
      \.database.fetchUserById .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode])
    )

    let conn = connection(
      from: request(
        to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(
      [],
      Current.database.fetchEpisodeCredits(user.id).run.perform().right!
    )
    XCTAssertEqual(
      1,
      Current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
    )
  }

  func testRedeemEpisodeCredit_AlreadyCredited() {
    let episode = Episode.mock
      |> \.permission .~ .free

    update(
      &Current, 
      \.episodes .~ unzurry([episode])
    )

    let user = Current.database
      .registerUser(.mock, "hello@pointfree.co")
      .run.perform().right!!
    _ = Current.database.updateUser(user.id, nil, nil, nil, 1, nil).run.perform()
    _ = Current.database.redeemEpisodeCredit(episode.sequence, user.id).run.perform()

    let credit = EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

    let conn = connection(
      from: request(
        to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
      )
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    XCTAssertEqual(
      [credit],
      Current.database.fetchEpisodeCredits(user.id).run.perform().right!
    )
    XCTAssertEqual(
      1,
      Current.database.fetchUserById(user.id).run.perform().right!!.episodeCreditCount
    )
  }

  func test_permission() {
    let start = Date(timeIntervalSinceReferenceDate: 0)
    let end = Date(timeIntervalSinceReferenceDate: 100)
    let episode = Episode.mock
      |> \.permission .~ .freeDuring(start..<end)

    update(&Current, \.date .~ { start.addingTimeInterval(-1) })
    XCTAssertTrue(episode.subscriberOnly)

    update(&Current, \.date .~ { start.addingTimeInterval(1) })
    XCTAssertFalse(episode.subscriberOnly)

    update(&Current, \.date .~ { end.addingTimeInterval(1) })
    XCTAssertTrue(episode.subscriberOnly)
  }

  func testEpisodePage_ExercisesAndReferences() {
    let episode = Current.episodes()[0]
      |> \.exercises .~ [.mock, .mock]
      |> \.references .~ [.mock]
      |> \.transcriptBlocks %~ { Array($0[0...1]) }

    update(
      &Current,
      \.database .~ .mock,
      \.episodes .~ { [episode] }
    )

    let conn = connection(
      from: request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)
    )

    #if !os(Linux)
    if self.isScreenshotTestingAvailable {
      let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
      let html = String(decoding: siteMiddleware(conn).perform().data, as: UTF8.self)
      webView.loadHTMLString(html, baseURL: nil)
      assertSnapshot(matching: webView, as: .image, named: "desktop")

      webView.frame.size.width = 500
      webView.frame.size.height = 1700
      assertSnapshot(matching: webView, as: .image, named: "mobile")

      webView.evaluateJavaScript("""
        document.getElementsByTagName('details')[0].open = true
        """)
      assertSnapshot(matching: webView, as: .image, named: "desktop-solution-open")
    }
    #endif

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }

  func testEpisodePage_Trialing() {
    update(&Current, \.database .~ .mock)

    var subscription = Subscription.mock
    subscription.stripeSubscriptionStatus = .trialing
    Current.database.fetchSubscriptionById = { _ in pure(subscription) }

    let episode = request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn(as: .mock))

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
  }
}
