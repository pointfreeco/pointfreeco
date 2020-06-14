extension Episode.Collection {
  public static let combine = Self(
    blurb: #"""
The Combine framework puts a powerful, reactive programming library in the hands of every person developing for Apple's platforms. We cover some of the framework's most foundational and mysterious aspects from first principles so that you can wield its power without getting in the zoo of types and operators.
"""#,
    sections: [
      .init(
        blurb: #"""
We used the Combine framework to power effects in the Composable Architecture, and so we provided a succinct, two part introduction to the basics of Combine. We discuss Combine's core concepts, such as publishers and subscribers, from first principles and show how they compare to concepts we've covered previously on Point-Free.
"""#,
        coreLessons: [
          .init(episode: .ep80_theCombineFrameworkAndEffects_pt1),
          .init(episode: .ep81_theCombineFrameworkAndEffects_pt2),
        ],
        related: [
          .init(
            blurb: #"""
We developed our own custom reactive type from first principles to model effects in the Composable Architecture, which we then later refactored to take advantage of Combine.
"""#,
            content: .episodes([
              .ep76_effectfulStateManagement_synchronousEffects,
              .ep77_effectfulStateManagement_unidirectionalEffects,
              .ep78_effectfulStateManagement_asynchronousEffects,
              .ep79_effectfulStateManagement_thePoint
            ])
          ),
        ],
        title: "Introduction",
        whereToGoFromHere: #"""
TODO
"""#
      ),
      .init(
        blurb: #"""
There's a lot of great material in the community covering almost every aspect of the Combine framework, but sadly Combine's `Scheduler` protocol hasn't gotten much attention. It's a pretty mysterious protocol, and Apple does not provide much docuemtnation about it, but it is incredibly powerful and can allow one to test how time flows through complex publishers.
"""#,
        coreLessons: [
          .init(episode: .ep104_combineSchedulers_testingTime),
          .init(episode: .ep105_combineSchedulers_controllingTime),
          .init(episode: .ep106_combineSchedulers_erasingTime),
        ],
        related: [
          .init(
            blurb: #"""
In the last part of our four-part tour of the [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) we demonstrate how to use the `TestScheduler` developed in this section to test a complex effect in a precise way.
"""#,
            content: .episodes([
              .ep103_ATourOfTheComposableArchitecture_pt4
            ])
          )
        ],
        title: "Schedulers",
        whereToGoFromHere: nil
      ),
    ],
    title: "Combine"
  )
}
