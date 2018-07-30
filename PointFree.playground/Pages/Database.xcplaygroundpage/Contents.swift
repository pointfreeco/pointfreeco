import Foundation
@testable import PointFree
import PointFreeTestSupport
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

Current.envVars.postgres.databaseUrl

Current.database.migrate().run.perform()

Current.database.fetchFreeEpisodeUsers()
  .run
  .perform()
  .right!

let user = Current.database.registerUser(.mock, "blob@pointfree.co")
  .run
  .perform()
  .right!!

user.episodeCreditCount

Current.database.incrementEpisodeCredits([user.id])
  .run
  .perform()
  .right!

let updatedUser = Current.database.fetchUserById(user.id)
  .run
  .perform()
  .right!!

updatedUser.episodeCreditCount
