@testable import AsyncHTTPClient
import GitHubTestSupport
import NIOCore
import PointFreeTestSupport
import SnapshotTesting
import XCTest

@testable import GitHub

@MainActor
final class GitHubTests: TestCase {
  func testRequests() async throws {
    let fetchAuthToken = fetchGitHubAuthToken(
      clientId: "deadbeef-client-id", clientSecret: "deadbeef-client-secret")
    try await assertSnapshot(
      matching: fetchAuthToken("deadbeef").rawValue,
      as: .raw,
      named: "fetch-auth-token"
    )
    await assertSnapshot(
      matching: fetchGitHubEmails(token: .mock).rawValue,
      as: .raw,
      named: "fetch-emails"
    )
    await assertSnapshot(
      matching: fetchGitHubUser(with: .mock).rawValue,
      as: .raw,
      named: "fetch-user"
    )
  }
}

extension Snapshotting where Value == HTTPClientRequest, Format == String {
  public static let raw = Snapshotting.raw(pretty: false)

  public static func raw(pretty: Bool) -> Snapshotting {
    return SimplySnapshotting.lines.pullback { (request: HTTPClientRequest) in
      let methodAndURL = "\(request.method.rawValue) \(request.url)"

      let headers = request.headers
        .map { key, value in "\(key): \(value)" }
        .sorted()

      let body: [String]
      do {
        if pretty, #available(iOS 11.0, macOS 10.13, tvOS 11.0, watchOS 4.0, *) {
          body = try await request.body?.buffer
            .map { try JSONSerialization.jsonObject(with: $0, options: []) }
            .map { try JSONSerialization.data(withJSONObject: $0, options: [.prettyPrinted, .sortedKeys]) }
            .map { ["\n\(String(decoding: $0, as: UTF8.self))"] }
            ?? []
        } else {
          throw NSError(domain: "co.pointfree.Never", code: 1, userInfo: nil)
        }
      }
      catch {
        if var buffer = try? await request.body?.buffer {
          body = ["\n\(buffer.readString(length: buffer.readableBytes) ?? "")"]
        } else {
          body = []
        }
      }

      return ([methodAndURL] + headers + body).joined(separator: "\n")
    }
  }
}

extension HTTPClientRequest.Body {
  var buffer: ByteBuffer? {
    get async throws {
      switch self.mode {
      case let .asyncSequence(_, makeAsyncIterator):
        return try await makeAsyncIterator()(ByteBufferAllocator())
      case let .sequence(_, _, makeCompleteBody):
        return makeCompleteBody(ByteBufferAllocator())
      case let .byteBuffer(buffer):
        return buffer
      }
    }
  }
}
