@testable import PointFree
import Foundation
import HttpPipeline

1

let session = Session(flash: nil, userId: .init(unwrap: UUID(uuidString: "f2d31034-0baf-11e8-9112-b3ffbeb2f840")!))

String(data: try! JSONEncoder().encode(session), encoding: .utf8)


"pf_session=eyJ1c2VySWQiOiJGMkQzMTAzNC0wQkFGLTExRTgtOTExMi1CM0ZGQkVCMkY4NDAifQ==--IwTBe4KXQ8+dAj288ksqjDwkXWl2O+ZD1B5nkLROAR4=; HttpOnly"

let userId = Database.User.Id.init(unwrap: UUID.init(uuidString: "f2d31034-0baf-11e8-9112-b3ffbeb2f840")!)

AppEnvironment.current.database
  .addEpisodePromo(5, userId)
  .run
  .perform()

AppEnvironment.current.database
  .fetchEpisodePromos(userId)
  .run
  .perform()
