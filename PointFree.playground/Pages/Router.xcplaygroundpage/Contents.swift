import Foundation
@testable import PointFree

let userId = Database.User.Id(unwrap: UUID(uuidString: "b317fc88-edba-11e7-b4d9-87032ec4d488")!)
print(url(to: .expressUnsubscribe(userId: userId, newsletter: .announcements)))

let urlString = "http://localhost:8080/newsletters/express-unsubscribe?data=bb8d83d7be64144d708cd6da946005978336f36c034d09f466899ef79be9eb9a14a637a715abe0389dd80bc9d47e43fe"

dump(router.match(string: urlString))
