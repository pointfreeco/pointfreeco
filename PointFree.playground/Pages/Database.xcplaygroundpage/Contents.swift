import Foundation
@testable import PointFree
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

Current.database.migrate().run.perform()

Current.database.fetchFreeEpisodeUsers()
  .run
  .perform()
  .right!



//Current.database
//  .insertTeamInvite(
//    "mcclane@pointfree.co",
//    Database.User.Id(rawValue: UUID(uuidString: "df73ae7c-e12f-11e7-82c0-afa1915eb872")!)
//    )
//  .run
//  .perform()
//
//Current.database
//  .fetchTeamInvite(.init(rawValue: UUID(uuidString: "5ba328c8-e131-11e7-a5f1-fbef0b8d9eca")!))
//  .run
//  .perform()
//
//1

