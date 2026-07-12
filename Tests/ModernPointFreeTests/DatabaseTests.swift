import CustomDump
import Database
import Dependencies
import Foundation
import GitHub
import Models
import Testing

@Suite(.database) struct DatabaseTests {
  @Dependency(\.database) var database

  @Test(arguments: 1...100) func createAndFetchUser(_: Int) async throws {
    let user = try await database.upsertUser(
      "deadbeef",
      GitHubUser(createdAt: .init(timeIntervalSince1970: 0), login: "blob", id: 1, name: "Blob"),
      "blob@pointfree.co",
      { .init(timeIntervalSince1970: 0) }
    )
    expectNoDifference(user.id, User.ID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!))

    let fetched = try await database.fetchUser(id: user.id)
    expectNoDifference(fetched.email, "blob@pointfree.co")
    expectNoDifference(fetched.name, "Blob")
  }

  // Deliberately identical to `createAndFetchUser`: both tests insert the first row of a fresh
  // database and expect the first deterministic UUID, which only holds if each test runs in its
  // own database.
  @Test func isolationFromOtherTests() async throws {
    let user = try await database.upsertUser(
      "deadbeef",
      GitHubUser(createdAt: .init(timeIntervalSince1970: 0), login: "blob", id: 1, name: "Blob"),
      "blob@pointfree.co",
      { .init(timeIntervalSince1970: 0) }
    )
    expectNoDifference(user.id, User.ID(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!))
  }
}
