import Database
import DatabaseTestSupport
import Dependencies
import Either
import GitHub
import GitHubTestSupport
import Html
import HttpPipeline
import Models
import ModelsTestSupport
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
import XCTest

@testable import PointFree

#if !os(Linux)
  import WebKit
#endif

@MainActor
class EpisodePageIntegrationTests: LiveDatabaseTestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testRedeemEpisodeCredit_HappyPath() async throws {
    var episode = Episode.mock
    episode.permission = .subscriberOnly

    try await withDependencies {
      $0.episodes = { [episode] }
    } operation: {
      let user = try await Current.database
        .registerUser(withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock })
      try await Current.database.updateUser(id: user.id, episodeCreditCount: 1)

      let credit = EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      let credits = try await Current.database.fetchEpisodeCredits(user.id)
      XCTAssertEqual([credit], credits)

      let count = try await Current.database.fetchUserById(user.id).episodeCreditCount
      XCTAssertEqual(0, count)
    }
  }

  func testRedeemEpisodeCredit_NotEnoughCredits() async throws {
    var episode = Episode.mock
    episode.permission = .subscriberOnly

    var user = User.mock
    user.episodeCreditCount = 0
    user.id = .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    try await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.episodes = { [episode] }
    } operation: {
      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      let credits = try await Current.database.fetchEpisodeCredits(user.id)
      XCTAssertEqual([], credits)

      let count = try await Current.database.fetchUserById(user.id).episodeCreditCount
      XCTAssertEqual(0, count)
    }
  }

  func testRedeemEpisodeCredit_PublicEpisode() async throws {
    var episode = Episode.mock
    episode.permission = .free

    var user = User.mock
    user.episodeCreditCount = 1
    user.id = .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    try await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.episodes = { [episode] }
    } operation: {
      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      let credits = try await Current.database.fetchEpisodeCredits(user.id)
      XCTAssertEqual([], credits)

      let count = try await Current.database.fetchUserById(user.id).episodeCreditCount
      XCTAssertEqual(1, count)
    }
  }

  func testRedeemEpisodeCredit_AlreadyCredited() async throws {
    var episode = Episode.mock
    episode.permission = .free

    try await withDependencies {
      $0.episodes = { [episode] }
    } operation: {
      let user = try await Current.database
        .registerUser(withGitHubEnvelope: .mock, email: "hello@pointfree.co", now: { .mock })
      _ = try await Current.database.updateUser(id: user.id, episodeCreditCount: 1)
      try await Current.database.redeemEpisodeCredit(episode.sequence, user.id)

      let credit = EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

      let conn = connection(
        from: request(
          to: .useEpisodeCredit(episode.id), session: Session.init(flash: nil, userId: user.id)
        )
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      let credits = try await Current.database.fetchEpisodeCredits(user.id)
      XCTAssertEqual([credit], credits)

      let count = try await Current.database.fetchUserById(user.id).episodeCreditCount
      XCTAssertEqual(1, count)
    }
  }
}

@MainActor
class EpisodePageTests: TestCase {
  override func setUp() async throws {
    try await super.setUp()
    //SnapshotTesting.isRecording = true
  }

  func testEpisodePage() async throws {
    let titles = ["Domain-Specific Languages", "Proof in Functions", "Composable Architecture"]
    let episodes = (0...2).map { idx -> Episode in
      var episode = Episode.mock
      episode.id = .init(rawValue: idx)
      episode.sequence = .init(rawValue: idx)
      episode.title = titles[idx]
      return episode
    }

    await withDependencies {
      $0.episodes = { episodes }
    } operation: {
      let episode = request(
        to: .episode(.show(.left(Current.episodes()[1].slug))), session: .loggedOut)

      let conn = connection(from: episode)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 2400)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 2400)),
            ]
          )
        }
      #endif
    }
  }

  func testEpisodePage_InCollectionContext() async throws {
    let episode = request(
      to: .collections(
        .collection(
          Current.collections[0].slug,
          .section(
            Current.collections[0].sections[0].slug,
            .episode(.left(Current.episodes()[0].slug))
          )
        )
      ),
      session: .loggedOut
    )

    let conn = connection(from: episode)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2400)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2400)),
          ]
        )
      }
    #endif
  }

  func testEpisodePage_InCollectionContext_LastEpisode() async throws {
    let episode = request(
      to: .collections(
        .collection(
          Current.collections[0].slug,
          .section(
            Current.collections[0].sections[0].slug,
            .episode(.left(Current.episodes()[1].slug))
          )
        )
      ),
      session: .loggedOut
    )

    let conn = connection(from: episode)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2400)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2400)),
          ]
        )
      }
    #endif
  }

  func testEpisodePageSubscriber() async throws {
    let episode = request(
      to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn)

    let conn = connection(from: episode)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshots(
          matching: conn |> siteMiddleware,
          as: [
            "desktop": .ioConnWebView(size: .init(width: 1100, height: 2600)),
            "mobile": .ioConnWebView(size: .init(width: 500, height: 2600)),
          ]
        )
      }
    #endif
  }

  func testEpisodePageSubscriber_Deactivated() async throws {
    let deactivated = update(Subscription.mock) { $0.deactivated = true }

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in deactivated }
      $0.database.fetchSubscriptionByOwnerId = { _ in deactivated }
    } operation: {
      let episode = request(
        to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn)

      let conn = connection(from: episode)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 2600)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 2600)),
            ]
          )
        }
      #endif
    }
  }

  func testFreeEpisodePage() async throws {
    var freeEpisode = Current.episodes()[0]
    freeEpisode.permission = .free

    await withDependencies {
      $0.episodes = { [freeEpisode] }
    } operation: {
      let episode = request(to: .episode(.show(.left(freeEpisode.slug))), session: .loggedOut)

      let conn = connection(from: episode)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 2100)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 2100)),
            ]
          )
        }
      #endif
    }
  }

  func testFreeEpisodePageSubscriber() async throws {
    var freeEpisode = Current.episodes()[0]
    freeEpisode.permission = .free

    await withDependencies {
      $0.episodes = { [freeEpisode] }
    } operation: {
      let episode = request(to: .episode(.show(.left(freeEpisode.slug))), session: .loggedIn)

      let conn = connection(from: episode)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 2100)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 2100)),
            ]
          )
        }
      #endif
    }
  }

  func testEpisodeNotFound() async throws {
    let episode = request(to: .episode(.show(.left("object-oriented-programming"))))

    let conn = connection(from: episode)

    await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
      if self.isScreenshotTestingAvailable {
        await assertSnapshot(
          matching: conn |> siteMiddleware,
          as: .ioConnWebView(size: .init(width: 1100, height: 1000))
        )
      }
    #endif
  }

  func testEpisodeCredit_PublicEpisode_NonSubscriber_UsedCredit() async throws {
    var user = Models.User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    var episode = Current.episodes()[1]
    episode.permission = .free

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchEpisodeCredits = { _ in [.mock] }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.episodes = { [episode] }
    } operation: {
      let conn = connection(
        from: request(to: .episode(.show(.left(episode.slug))), session: .loggedIn)
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 1800)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 1800)),
            ]
          )
        }
      #endif
    }
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_UsedCredit() async throws {
    var user = Models.User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    var episode = Current.episodes()[1]
    episode.permission = .subscriberOnly

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.database.fetchEpisodeCredits = { _ in [.mock] }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
      $0.episodes = { [episode] }
    } operation: {
      let conn = connection(
        from: request(
          to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn)
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 1800)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 1800)),
            ]
          )
        }
      #endif
    }
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_HasCredits() async throws {
    var user = Models.User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 1

    var episode = Current.episodes().first!
    episode.permission = .subscriberOnly

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.episodes = { [episode] }
      $0.database.fetchEpisodeCredits = { _ in [] }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn)
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 2300)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 2300)),
            ]
          )
        }
      #endif
    }
  }

  func testEpisodeCredit_PrivateEpisode_NonSubscriber_NoCredits() async throws {
    var user = Models.User.mock
    user.subscriptionId = nil
    user.episodeCreditCount = 0

    var episode = Current.episodes().first!
    episode.permission = .subscriberOnly

    await withDependencies {
      $0.database.fetchUserById = { _ in user }
      $0.episodes = { [episode] }
      $0.database.fetchEpisodeCredits = { _ in [] }
      $0.database.fetchSubscriptionByOwnerId = { _ in throw unit }
    } operation: {
      let conn = connection(
        from: request(
          to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn)
      )

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          await assertSnapshots(
            matching: conn |> siteMiddleware,
            as: [
              "desktop": .ioConnWebView(size: .init(width: 1100, height: 2300)),
              "mobile": .ioConnWebView(size: .init(width: 500, height: 2300)),
            ]
          )
        }
      #endif
    }
  }

  func test_permission() async throws {
    let start = Date(timeIntervalSinceReferenceDate: 0)
    let end = Date(timeIntervalSinceReferenceDate: 100)
    var episode = Episode.mock
    episode.permission = .freeDuring(start..<end)

    withDependencies {
      $0.date.now = start.addingTimeInterval(-1)
    } operation: {
      XCTAssertTrue(episode.subscriberOnly)
    }

    withDependencies {
      $0.date.now = start.addingTimeInterval(1)
    } operation: {
      XCTAssertFalse(episode.subscriberOnly)
    }

    withDependencies {
      $0.date.now = end.addingTimeInterval(1)
    } operation: {
      XCTAssertTrue(episode.subscriberOnly)
    }
  }

  func testEpisodePage_ExercisesAndReferences() async throws {
    var episode = Current.episodes()[0]
    episode.exercises = [.mock, .mock]
    episode.references = [.mock]
    episode.transcriptBlocks = Array(episode.transcriptBlocks[0...1])

    try await withDependencies {
      $0.episodes = { [episode] }
      $0.renderHtml = { Html.render($0) }
    } operation: {
      let conn = connection(
        from: request(
          to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn)
      )

      #if !os(Linux)
        if self.isScreenshotTestingAvailable {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1100, height: 1600))
          let html = await String(
            decoding: siteMiddleware(conn).performAsync().data, as: UTF8.self
          )
          webView.loadHTMLString(html, baseURL: nil)
          await assertSnapshot(matching: webView, as: .image, named: "desktop")

          webView.frame.size.width = 500
          webView.frame.size.height = 1700
          await assertSnapshot(matching: webView, as: .image, named: "mobile")

          try await webView.evaluateJavaScript(
            """
            document.getElementsByTagName('details')[0].open = true
            """
          )
          await assertSnapshot(matching: webView, as: .image, named: "desktop-solution-open")
        }
      #endif

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testEpisodePage_Trialing() async throws {
    var subscription = Subscription.mock
    subscription.stripeSubscriptionStatus = .trialing

    await withDependencies {
      $0.database.fetchSubscriptionById = { _ in subscription }
    } operation: {
      let episode = request(
        to: .episode(.show(.left(Current.episodes().first!.slug))), session: .loggedIn(as: .mock))

      let conn = connection(from: episode)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }

  func testProgress_LoggedIn() async throws {
    var didUpdate = false

    await withDependencies {
      $0.database.updateEpisodeProgress = { _, _, _ in didUpdate = true }
    } operation: {
      let episode = Current.episodes().first!
      let percent = 20
      let progressRequest = request(
        to: .episode(.progress(param: .left(episode.slug), percent: percent)),
        session: .loggedIn
      )
      let conn = connection(from: progressRequest)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertEqual(didUpdate, true)
    }
  }

  func testProgress_LoggedOut() async throws {
    var didUpdate = false
    await withDependencies {
      $0.database.updateEpisodeProgress = { _, _, _ in didUpdate = true }
    } operation: {
      let episode = Current.episodes().first!
      let percent = 20
      let progressRequest = request(
        to: .episode(.progress(param: .left(episode.slug), percent: percent)),
        session: .loggedOut
      )
      let conn = connection(from: progressRequest)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
      XCTAssertEqual(didUpdate, false)
    }
  }

  func testEpisodePage_WithEpisodeProgress() async throws {
    await withDependencies {
      $0.database.fetchEpisodeProgress = { _, _ in pure(20) }
    } operation: {
      let episode = request(
        to: .episode(.show(.left(Current.episodes()[1].slug))), session: .loggedIn)

      let conn = connection(from: episode)

      await assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)
    }
  }
}
