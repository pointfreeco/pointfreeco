import Foundation
@testable import PointFree
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

Current.database.migrate().run.perform()

Current.database.fetchFreeEpisodeUsers()
  .run
  .perform()
  .right!
