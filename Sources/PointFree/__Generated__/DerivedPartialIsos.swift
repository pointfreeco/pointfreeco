// Generated using Sourcery 0.9.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import ApplicativeRouter
import Prelude

  extension GitHubRoute {
    enum iso {
          public static let authorize = parenthesize <| PartialIso(
            apply: GitHubRoute.authorize,
            unapply: {
              guard case let .authorize(result) = $0 else { return nil }
              return result
          })
          public static let episodeCodeSample = parenthesize <| PartialIso(
            apply: GitHubRoute.episodeCodeSample,
            unapply: {
              guard case let .episodeCodeSample(result) = $0 else { return nil }
              return result
          })
          public static let license = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
            apply: const(.some(.license)),
            unapply: {
              guard case .license = $0 else { return nil }
              return unit
          })
          public static let organization = parenthesize <| PartialIso<Prelude.Unit, GitHubRoute>(
            apply: const(.some(.organization)),
            unapply: {
              guard case .organization = $0 else { return nil }
              return unit
          })
          public static let repo = parenthesize <| PartialIso(
            apply: GitHubRoute.repo,
            unapply: {
              guard case let .repo(result) = $0 else { return nil }
              return result
          })
    }
  }
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
          public static let subscribe = parenthesize <| PartialIso(
            apply: Route.subscribe,
            unapply: {
              guard case let .subscribe(result) = $0 else { return nil }
              return result
          })
          public static let terms = parenthesize <| PartialIso<Prelude.Unit, Route>(
            apply: const(.some(.terms)),
            unapply: {
              guard case .terms = $0 else { return nil }
              return unit
          })
    }
  }
  extension TwitterRoute {
    enum iso {
          public static let mbrandonw = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
            apply: const(.some(.mbrandonw)),
            unapply: {
              guard case .mbrandonw = $0 else { return nil }
              return unit
          })
          public static let pointfreeco = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
            apply: const(.some(.pointfreeco)),
            unapply: {
              guard case .pointfreeco = $0 else { return nil }
              return unit
          })
          public static let stephencelis = parenthesize <| PartialIso<Prelude.Unit, TwitterRoute>(
            apply: const(.some(.stephencelis)),
            unapply: {
              guard case .stephencelis = $0 else { return nil }
              return unit
          })
    }
  }
