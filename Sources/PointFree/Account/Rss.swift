import Foundation
import Html
import HttpPipeline
import Prelude
import Tuple

let accountRssMiddleware: Middleware<StatusLineOpen, ResponseEnded, Tuple2<Database.User.Id, Database.User.RssSalt>, Data> =
{ fetchUser >=> $0 }
  <<< filterMap(
    require1 >>> pure,
    // todo: redirect to atom feed with error summary
    or: redirect(to: .home)
  )
  <<< validateUserAndSalt
  <| writeStatus(.ok)
  >=> respond(feedView, contentType: .application(.atom))

private func validateUserAndSalt<Z>(
  _ middleware: @escaping Middleware<StatusLineOpen, ResponseEnded, Database.User, Data>)
  -> Middleware<StatusLineOpen, ResponseEnded, T3<Database.User, Database.User.RssSalt, Z>, Data> {

    return { conn in
      guard get1(conn.data).rssSalt == get2(conn.data) else {
        // todo: redirect to atom feed with error summary
        return conn
          |> redirect(to: .home)
      }
      return conn.map(const(get1(conn.data)))
        |> middleware
    }
}

private let feedView = View<Database.User> { user in
  atomLayout.view(
    AtomFeed(
      author: AtomAuthor(
        email: "support@pointfree.co",
        name: "Point-Free"
      ),
      entries: [],
      atomUrl: url(to: .account(.rss(userId: user.id, rssSalt: user.rssSalt))),
      siteUrl: url(to: .home),
      title: "Point-Free Episode Videos"
    )
  )
}

// todo: atom feed subtitle for description and disclaimer

private func atomEntry(for episode: Episode, user: Database.User) -> AtomEntry {
  fatalError()
}
