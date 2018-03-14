@testable import ApplicativeRouter
import Prelude

func namespace<A>(_ n: String) -> (Router<A>) -> Router<A> {

  return { router in

    Router<A>(
      parse: { data in


        let tmp = uncons(data.path)
          .flatMap { p, ps in
            p == n
              ? router.parse(.init(method: data.method, path: ps, query: data.query, body: data.body))
              : nil
        }


        return tmp

    },
      print: { a in

        let tmp = router.print(a).map { x in
          .init(method: nil, path: [n], query: [:], body: nil) <> x
        }

        return tmp


    },
      template: { _ in fatalError() }
    )
  }
}

