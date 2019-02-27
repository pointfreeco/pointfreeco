// Generated using Sourcery 0.15.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import ApplicativeRouter
import Either
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Stripe



      extension PartialIso where A == (
            String
          , 
            String?
          , 
            String
        ), B == GitHubRoute {

          public static let authorize = parenthesize <| PartialIso(
            apply: GitHubRoute.authorize,
            unapply: {
              guard case let .authorize(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == (
            String
        ), B == GitHubRoute {

          public static let episodeCodeSample = parenthesize <| PartialIso(
            apply: GitHubRoute.episodeCodeSample,
            unapply: {
              guard case let .episodeCodeSample(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == GitHubRoute {
        public static let license = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
          apply: const(.some(.license)),
          unapply: {
            guard case .license = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == GitHubRoute {
        public static let organization = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
          apply: const(.some(.organization)),
          unapply: {
            guard case .organization = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == (
            GitHubRoute.Repo
        ), B == GitHubRoute {

          public static let repo = parenthesize <| PartialIso(
            apply: GitHubRoute.repo,
            unapply: {
              guard case let .repo(result) = $0 else { return nil }
              return .some(result)
          })
      }



      extension PartialIso where A == Prelude.Unit, B == TwitterRoute {
        public static let mbrandonw = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
          apply: const(.some(.mbrandonw)),
          unapply: {
            guard case .mbrandonw = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == TwitterRoute {
        public static let pointfreeco = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
          apply: const(.some(.pointfreeco)),
          unapply: {
            guard case .pointfreeco = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }



      extension PartialIso where A == Prelude.Unit, B == TwitterRoute {
        public static let stephencelis = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
          apply: const(.some(.stephencelis)),
          unapply: {
            guard case .stephencelis = $0 else { return nil }
            return .some(Prelude.unit)
        })
      }

