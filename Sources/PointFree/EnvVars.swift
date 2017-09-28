import Foundation

enum EnvVars {
  static let airbaseBase1 = ProcessInfo.processInfo.environment["AIRTABLE_BASE_1"] ?? "deadbeef-base-1"
  static let airbaseBase2 = ProcessInfo.processInfo.environment["AIRTABLE_BASE_2"] ?? "deadbeef-base-2"
  static let airbaseBase3 = ProcessInfo.processInfo.environment["AIRTABLE_BASE_3"] ?? "deadbeef-base-3"
  static let airtableBearer = ProcessInfo.processInfo.environment["AIRTABLE_BEARER"] ?? "deadbeef-bearer"


  enum GitHub {
    static let clientId = ProcessInfo.processInfo.environment["GITHUB_CLIENT_ID"] ?? "deadbeef-gh-client-id"
    static let clientSecret = ProcessInfo.processInfo.environment["GITHUB_CLIENT_SECRET"] ?? "deadbeef-gh-client-secret"
  }
}
