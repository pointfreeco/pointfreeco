extension Episode.Collection {
  public static let composableArchitecture = Self(
    blurb: #"""
Architecture is a tough problem and there's no shortage of articles, videos and open source projects attempting to solve the problem once and for all. We systemically develop an architecture from first principles, with an eye on building something that is composable, modular, testable, and more.
"""#,
    sections: [
      .init(
        blurb: #"""
We begin our exploration of application architecture by understanding the core problems that any architecture aims to solve, and we will explore these problems by seeing how SwiftUI approaches state management. This will lead us to formulating the 5 big problems that must be solved, and will guide the development of our architecture from this point forward:

* How to manage state across an entire application
* How to model the architecture with simple units, such as value types.
* How to modularize an application built in the architecture.
* How to model side effects in the architecture
* How to easily write comprehensive tests for features built in the architecture.
"""#,
        coreLessons: [
          .init(episode: .ep65_swiftuiAndStateManagement_pt1),
          .init(episode: .ep66_swiftuiAndStateManagement_pt2),
          .init(episode: .ep67_swiftuiAndStateManagement_pt3),
        ],
        related: [
        ],
        title: "SwiftUI and State Managment",
        whereToGoFromHere: #"""
TODO
"""#
      ),
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep68_composableStateManagement_reducers),
          .init(episode: .ep69_composableStateManagement_statePullbacks),
          .init(episode: .ep70_composableStateManagement_actionPullbacks),
          .init(episode: .ep71_composableStateManagement_higherOrderReducers),
        ],
        related: [
          .init(
            blurb: #"""
TODO
"""#,
            content: .episode(.ep65_swiftuiAndStateManagement_pt1)
          )
        ],
        title: "Reducers and Stores",
        whereToGoFromHere: #"""
TODO
"""#
      ),
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep72_modularStateManagement_reducers),
          .init(episode: .ep73_modularStateManagement_viewState),
          .init(episode: .ep74_modularStateManagement_viewActions),
          .init(episode: .ep75_modularStateManagement_thePoint),
        ],
        related: [
          // TODO
        ],
        title: "Modularity",
        whereToGoFromHere: #"""
TODO
"""#
      ),
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep76_effectfulStateManagement_synchronousEffects),
          .init(episode: .ep77_effectfulStateManagement_unidirectionalEffects),
          .init(episode: .ep78_effectfulStateManagement_asynchronousEffects),
          .init(episode: .ep79_effectfulStateManagement_thePoint),
        ],
        related: [
          .init(
            blurb: """
TODO
""",
            content: .episodes([
              .ep80_theCombineFrameworkAndEffects_pt1,
              .ep81_theCombineFrameworkAndEffects_pt2,
            ])
          )
        ],
        title: "Side Effects",
        whereToGoFromHere: #"""
TODO
"""#
      ),
      .init(
        blurb: #"""
TODO
"""#,
        coreLessons: [
          .init(episode: .ep82_testableStateManagement_reducers),
          .init(episode: .ep83_testableStateManagement_effects),
          .init(episode: .ep84_testableStateManagement_ergonomics),
          .init(episode: .ep85_testableStateManagement_thePoint),
        ],
        related: [
          .init(
            blurb: #"""
TODO
"""#,
            content: .episode(.ep16_dependencyInjectionMadeEasy)
          ),
          // TODO
        ],
        title: "Testing",
        whereToGoFromHere: #"""
TODO
"""#
      ),
    ],
    title: "Composable Architecture"
  )
}
