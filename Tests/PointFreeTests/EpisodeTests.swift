import Either
import Html
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
    update(&Current, \.database .~ .mock)
//    record = true
  }

  func testEpisodePage() {
    let episode = request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedOut)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

  func testEpisodePageSubscriber() {
    let episode = request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2300)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2300))
        ]
      )
    }
    #endif
  }

  func testFreeEpisodePage() {
    let freeEpisode = Current.episodes()[0]
      |> \.permission .~ .free

    update(&Current, \.episodes .~ { [freeEpisode] })

    let episode = request(to: .episode(.left(freeEpisode.slug)), session: .loggedOut)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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

    update(&Current, \.episodes .~ { [freeEpisode] })

    let episode = request(to: .episode(.left(freeEpisode.slug)), session: .loggedIn)

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    let episode = request(to: .episode(.left("object-oriented-programming")))

    let conn = connection(from: episode)

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshot(
        matching: conn |> siteMiddleware,
        as: .ioConnWebView(size: .init(width: 1100, height: 1000))
      )
    }
    #endif
  }

  func testEpisodeCredit_PublicEpisode_NonSubscriber_UsedCredit() {
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = Current.episodes()[1]
      |> \.permission .~ .free

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode]),
      \.database.fetchEpisodeCredits .~ const(pure([.mock])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .episode(.left(episode.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = Current.episodes()[1]
      |> \.permission .~ .subscriberOnly

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode]),
      \.database.fetchEpisodeCredits .~ const(pure([.mock])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
    let user = Database.User.mock
      |> \.subscriptionId .~ nil
      |> \.episodeCreditCount .~ 1

    let episode = Current.episodes().first!
      |> \.permission .~ .subscriberOnly

    update(
      &Current,
      (\Environment.database.fetchUserById) .~ const(pure(.some(user))),
      \.episodes .~ unzurry([episode]),
      \.database.fetchEpisodeCredits .~ const(pure([])),
      \.database.fetchSubscriptionByOwnerId .~ const(pure(nil))
    )

    let conn = connection(
      from: request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
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
      \.database .~ .live,
      \.episodes .~ unzurry([episode])
    )

    let user = Current.database
      .registerUser(.mock, "hello@pointfree.co")
      .run.perform().right!!
    _ = Current.database.updateUser(user.id, nil, nil, nil, 1).run.perform()

    let credit = Database.EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

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

    let user = Database.User.mock
      |> \.episodeCreditCount .~ 0
      |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    update(
      &Current,
      \.database .~ .live,
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

    let user = Database.User.mock
      |> \.episodeCreditCount .~ 1
      |> \.id .~ .init(rawValue: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)

    update(
      &Current,
      \.database .~ .live,
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
      \.database .~ .live,
      \.episodes .~ unzurry([episode])
    )

    let user = Current.database
      .registerUser(.mock, "hello@pointfree.co")
      .run.perform().right!!
    _ = Current.database.updateUser(user.id, nil, nil, nil, 1).run.perform()
    _ = Current.database.redeemEpisodeCredit(episode.sequence, user.id).run.perform()

    let credit = Database.EpisodeCredit(episodeSequence: episode.sequence, userId: user.id)

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
      |> \.exercises .~ [.mock]
      |> \.references .~ [.mock]
      |> \.transcriptBlocks %~ { Array($0[0...1]) }

    update(
      &Current,
      \.episodes .~ { [episode] }
    )

    let conn = connection(
      from: request(to: .episode(.left(Current.episodes().first!.slug)), session: .loggedIn)
    )

    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 1600)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 1900))
        ]
      )
    }
    #endif
  }

}
