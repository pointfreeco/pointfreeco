// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import ApplicativeRouter
import Prelude

  extension Route {
    enum iso {
            public static let about = parenthesize <| PartialIso<Prelude.Unit, Route>(
              apply: const(.some(.about)),
              unapply: {
                guard case .about = $0 else { return nil }
                return unit
            })
            public static let episode = parenthesize <| PartialIso(
              apply: Route.episode,
              unapply: {
                guard case let .episode(result) = $0 else { return nil }
                return result
            })
            public static let episodes = parenthesize <| PartialIso(
              apply: Route.episodes,
              unapply: {
                guard case let .episodes(result) = $0 else { return nil }
                return result
            })
            public static let gitHubCallback = parenthesize <| PartialIso(
              apply: Route.gitHubCallback,
              unapply: {
                guard case let .gitHubCallback(result) = $0 else { return nil }
                return result
            })
            public static let home = parenthesize <| PartialIso(
              apply: Route.home,
              unapply: {
                guard case let .home(result) = $0 else { return nil }
                return result
            })
            public static let launchSignup = parenthesize <| PartialIso(
              apply: Route.launchSignup,
              unapply: {
                guard case let .launchSignup(result) = $0 else { return nil }
                return result
            })
            public static let login = parenthesize <| PartialIso(
              apply: Route.login,
              unapply: {
                guard case let .login(result) = $0 else { return nil }
                return result
            })
            public static let logout = parenthesize <| PartialIso<Prelude.Unit, Route>(
              apply: const(.some(.logout)),
              unapply: {
                guard case .logout = $0 else { return nil }
                return unit
            })
            public static let pricing = parenthesize <| PartialIso(
              apply: Route.pricing,
              unapply: {
                guard case let .pricing(result) = $0 else { return nil }
                return result
            })
            public static let secretHome = parenthesize <| PartialIso<Prelude.Unit, Route>(
              apply: const(.some(.secretHome)),
              unapply: {
                guard case .secretHome = $0 else { return nil }
                return unit
            })
            public static let terms = parenthesize <| PartialIso<Prelude.Unit, Route>(
              apply: const(.some(.terms)),
              unapply: {
                guard case .terms = $0 else { return nil }
                return unit
            })
    }
  }
