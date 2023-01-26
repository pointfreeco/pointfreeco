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
import VimeoClient

@testable import PointFree

#if !os(Linux)
import WebKit
#endif

@MainActor
class ResumeTests: TestCase {
  func testNotLoggedIn() async {
    let conn = await siteMiddleware(connection(from: request(to: .resume)))
    await _assertInlineSnapshot(matching: conn, as: .conn, with: """
    GET http://localhost:8080/resume
    Cookie: pf_session={}

    302 Found
    Location: /login?redirect=http://localhost:8080/resume
    Referrer-Policy: strict-origin-when-cross-origin
    X-Content-Type-Options: nosniff
    X-Download-Options: noopen
    X-Frame-Options: SAMEORIGIN
    X-Permitted-Cross-Domain-Policies: none
    X-XSS-Protection: 1; mode=block
    """)
  }

  func testNoEpisodeProgress() async {
    await withDependencies {
      $0.episodeProgresses = [:]
    } operation: {
      let conn = connection(from: request(to: .resume, session: .loggedIn))
      await _assertInlineSnapshot(matching: await siteMiddleware(conn), as: .conn, with: """
      GET http://localhost:8080/resume
      Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}

      302 Found
      Location: /
      Referrer-Policy: strict-origin-when-cross-origin
      Set-Cookie: pf_session={"flash":{"message":"You are not currently watching any episodes.","priority":"warning"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
      X-Content-Type-Options: nosniff
      X-Download-Options: noopen
      X-Frame-Options: SAMEORIGIN
      X-Permitted-Cross-Domain-Policies: none
      X-XSS-Protection: 1; mode=block
      """)
    }
  }

  func testUnfinishedEpisodeProgress() async {
    await withDependencies {
      $0.database.fetchEpisodeProgresses = { _ in
        [
          EpisodeProgress(
            createdAt: .mock,
            episodeSequence: 1,
            id: EpisodeProgress.ID(),
            isFinished: false,
            percent: 50,
            userID: User.ID(),
            updatedAt: .mock
          )
        ]
      }
    } operation: {
      let conn = connection(from: request(to: .resume, session: .loggedIn))
      await _assertInlineSnapshot(matching: await siteMiddleware(conn), as: .conn, with: """
      GET http://localhost:8080/resume
      Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
      
      302 Found
      Location: /episodes/ep1-type-safe-html-in-swift
      Referrer-Policy: strict-origin-when-cross-origin
      Set-Cookie: pf_session={"flash":{"message":"Resuming your last watched episode.","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
      X-Content-Type-Options: nosniff
      X-Download-Options: noopen
      X-Frame-Options: SAMEORIGIN
      X-Permitted-Cross-Domain-Policies: none
      X-XSS-Protection: 1; mode=block
      """)
    }
  }

  func testAllCaughtUp() async {
    await withDependencies {
      $0.episodes = {
        [
          Episode(
            blurb: "",
            id: 1,
            length: 1,
            permission: .free,
            publishedAt: .mock,
            sequence: 1,
            title: "",
            trailerVideo: Episode.Video(
              bytesLength: 1,
              downloadUrls: .s3(hd1080: "", hd720: "", sd540: ""),
              vimeoId: 1
            )
          )
        ]
      }
      $0.database.fetchEpisodeProgresses = { _ in
        [
          EpisodeProgress(
            createdAt: .mock,
            episodeSequence: 1,
            id: EpisodeProgress.ID(),
            isFinished: true,
            percent: 50,
            userID: User.ID(),
            updatedAt: .mock
          )
        ]
      }
    } operation: {
      let conn = connection(from: request(to: .resume, session: .loggedIn))
      await _assertInlineSnapshot(matching: await siteMiddleware(conn), as: .conn, with: """
      GET http://localhost:8080/resume
      Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
      
      302 Found
      Location: /
      Referrer-Policy: strict-origin-when-cross-origin
      Set-Cookie: pf_session={"flash":{"message":"You‘re all caught up!","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
      X-Content-Type-Options: nosniff
      X-Download-Options: noopen
      X-Frame-Options: SAMEORIGIN
      X-Permitted-Cross-Domain-Policies: none
      X-XSS-Protection: 1; mode=block
      """)
    }
  }

  func testStartingNextEpisode() async {
    await withDependencies {
      $0.episodes = {
        [
          Episode(
            blurb: "",
            id: 1,
            length: 1,
            permission: .free,
            publishedAt: .mock,
            sequence: 1,
            title: "",
            trailerVideo: Episode.Video(
              bytesLength: 1,
              downloadUrls: .s3(hd1080: "", hd720: "", sd540: ""),
              vimeoId: 1
            )
          ),
          Episode(
            blurb: "",
            id: 2,
            length: 1,
            permission: .free,
            publishedAt: .mock,
            sequence: 2,
            title: "",
            trailerVideo: Episode.Video(
              bytesLength: 1,
              downloadUrls: .s3(hd1080: "", hd720: "", sd540: ""),
              vimeoId: 1
            )
          )
        ]
      }
      $0.database.fetchEpisodeProgresses = { _ in
        [
          EpisodeProgress(
            createdAt: .mock,
            episodeSequence: 1,
            id: EpisodeProgress.ID(),
            isFinished: true,
            percent: 50,
            userID: User.ID(),
            updatedAt: .mock
          )
        ]
      }
    } operation: {
      let conn = connection(from: request(to: .resume, session: .loggedIn))
      await _assertInlineSnapshot(matching: await siteMiddleware(conn), as: .conn, with: """
      GET http://localhost:8080/resume
      Cookie: pf_session={"userId":"00000000-0000-0000-0000-000000000000"}
      
      302 Found
      Location: /episodes/ep2-
      Referrer-Policy: strict-origin-when-cross-origin
      Set-Cookie: pf_session={"flash":{"message":"Starting the next episode.","priority":"notice"},"userId":"00000000-0000-0000-0000-000000000000"}; Expires=Sat, 29 Jan 2028 00:00:00 GMT; Path=/
      X-Content-Type-Options: nosniff
      X-Download-Options: noopen
      X-Frame-Options: SAMEORIGIN
      X-Permitted-Cross-Domain-Policies: none
      X-XSS-Protection: 1; mode=block
      """)
    }
  }
}
