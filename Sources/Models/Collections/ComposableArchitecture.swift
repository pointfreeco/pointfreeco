extension Episode.Collection {
  public static let composableArchitecture = Self(
    blurb: #"""
TODO
"""#,
    sections: [
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
        slug: "reducers-and-stores",
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
        slug: "modularity",
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

          .init(episode: .ep80_theCombineFrameworkAndEffects_pt1), // Optional/Related?
          .init(episode: .ep81_theCombineFrameworkAndEffects_pt2), // Optional/Related?
        ],
        related: [
          // TODO
        ],
        slug: "side-effects",
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
        slug: "testing",
        title: "Testing",
        whereToGoFromHere: #"""
TODO
"""#
      ),
    ],
    slug: "composable-architecture",
    title: "Composable Architecture"
  )
}
