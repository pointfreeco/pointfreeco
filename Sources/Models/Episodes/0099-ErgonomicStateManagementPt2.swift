import Foundation

extension Episode {
  public static let ep99_ergonomicStateManagement_pt2 = Episode(
    blurb: """
      We've made creating and enhancing reducers more ergonomic, but we still haven't given much attention to the ergonomics of the view layer of the Composable Architecture. This week we'll make the Store much nicer to use by taking advantage of a new Swift feature and by enhancing it with a SwiftUI helper.
      """,
    codeSampleDirectory: "0099-ergonomic-state-management-pt2",
    exercises: _exercises,
    fullVideo: nil,
    id: 99,
    length: 24 * 60 + 3,
    permission: .subscriberOnly,
    publishedAt: Date(timeIntervalSince1970: 1_587_358_800),
    references: [
      // TODO
    ],
    sequence: 99,
    subtitle: "Part 2",
    title: "Ergonomic State Management",
    trailerVideo: .init(
      bytesLength: 20_290_250,
      downloadUrls: .s3(
        hd1080: "0099-trailer-1080p-b1ba2eac852a4ddab00fb04cf6a278dc",
        hd720: "0099-trailer-720p-4945c30d4f8e453fb3e4d56ffc6ca27d",
        sd540: "0099-trailer-540p-47be93c7ce9d4f3193cdb1c63c1cd01b"
      ),
      vimeoId: 409_489_458
    )
  )
}

private let _exercises: [Episode.Exercise] = [
  .init(
    problem: #"""
      Let's add a little more polish to the Composable Architecture. Right now there is no easy way of working with optional state. In particular, it is not possible to write a reducer on non-optional state and use `pullback` to transform it to a reducer that works on optional state.

      Define a custom property on `Reducer` that transforms reducers on non-optional state to reducers on optional state.
      """#,
    solution: #"""
      ```swift
      extension Reducer {
        public var optional: Reducer<Value?, Action, Environment> {
          .init { value, action, environment in
            guard value != nil else { return [] }
            return self(&value!, action, environment)
          }
        }
      }
      ```
      """#
  ),
  .init(
    problem: #"""
      There is also no easy way of working with collections in state. In particular, it is not possible to write a reducer on an element of state and use `pullback` to transform it to a reducer that works on a collection of state.

      Define an `indexed` method on `Reducer` that handles this kind of transformation such that the state's key path is of the form `WritableKeyPath<GlobalValue, [Value]>`. In order to send an action to a particular element of the array, it must identify the element in some way. Take inspiration from the method's name. 😁
      """#,
    solution: #"""
      Given some global app state:

      ```swift
      struct AppState {
        var list: [RowState]
      }
      ```

      In order to send actions to individual elements, you can identify them by index.

      ```swift
      enum AppAction {
        case list(index: Int, action: RowAction)
      }
      ```

      Which means that `indexed` would take a case path from `AppAction` to `(Int, Action)`.

      From this we can deduce the signature and define the following method:

      ```swift
      extension Reducer {
        func indexed<GlobalValue, GlobalAction, GlobalEnvironment>(
          value: WritableKeyPath<GlobalValue, [Value]>,
          action: CasePath<GlobalAction, (Int, Action)>,
          environment: @escaping (GlobalEnvironment) -> Environment
        ) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
          .init { globalValue, globalAction, globalEnvironment in
            guard
              let (index, localAction) = action.extract(from: globalAction)
              else { return [] }
            return self(
              &globalValue[keyPath: value][index],
              localAction,
              environment(globalEnvironment)
            )
            .map { effect in
              effect
                .map { action.embed((index, $0)) }
                .eraseToEffect()
            }
          }
        }
      }
      ```
      """#
  ),
]
