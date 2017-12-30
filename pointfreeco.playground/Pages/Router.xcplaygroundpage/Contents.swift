import Foundation
@testable import PointFree

let userId = Database.User.Id(unwrap: UUID(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!)
print(url(to: .expressUnsubscribe(userId: userId, newsletter: .newEpisode)))

let urlString = "http://localhost:8080/newsletters/96194ec41e1b962c516711f966088a6d37cf9548d89e1de4fc6563b185a020eecf4cc5616264af6f3062140c50058fef/express-unsubscribe?user_id=dd8a725f0d6f36fe9a37a36660358e7"

dump(router.match(string: urlString))

