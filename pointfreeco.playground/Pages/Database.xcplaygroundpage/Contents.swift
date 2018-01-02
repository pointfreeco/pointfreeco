import Foundation
@testable import PointFree
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

AppEnvironment.current.database.migrate().run.perform()

//AppEnvironment.current.database
//  .fetchUserById(Database.User.Id(unwrap: UUID(uuidString: "df73ae7c-e12f-11e7-82c0-afa1915eb872")!))
//  .run
//  .perform()

AppEnvironment.current.database
  .registerUser(.init(accessToken: .init(accessToken: "deadbeef"), gitHubUser: .init(avatarUrl: "", email: .init(unwrap: "me@pointfree.co"), id: .init(unwrap: 123), name: "Blob")))
//  .run
//  .perform()

AppEnvironment.current.database.insertTeamInvite(.init(unwrap: "blobby@pointfree.co"), .init(unwrap: UUID(uuidString: "09d24b2e-f003-11e7-99e6-7b2c2cf94951")!))
  .run
  .perform()

//AppEnvironment.current.database.addUserIdToSubscriptionId(
//  .init(unwrap: UUID(uuidString: "0e74ece2-e665-11e7-9c23-4b6dbc10be70")!),
//  .init(unwrap: UUID(uuidString: "5dda18fa-e662-11e7-b1dd-fb29b9a4f405")!)
//)
//.run
//.perform()

//AppEnvironment.current.database
//  .insertTeamInvite(
//    EmailAddress(unwrap: "mcclane@pointfree.co"),
//    Database.User.Id(unwrap: UUID(uuidString: "df73ae7c-e12f-11e7-82c0-afa1915eb872")!)
//    )
//  .run
//  .perform()
//
//AppEnvironment.current.database
//  .fetchTeamInvite(.init(unwrap: UUID(uuidString: "5ba328c8-e131-11e7-a5f1-fbef0b8d9eca")!))
//  .run
//  .perform()
//
1

