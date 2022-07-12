import Foundation

extension Episode {
  public static let ep101_ATourOfTheComposableArchitecture_pt2 = Episode(
    blurb: """
      Continuing the tour of our recently open-sourced library, the Composable Architecture, we start to employ some of the more advanced tools that come with the library. Right now our business logic and view is riddled with needless array index juggling, and a special higher-order reducer can clean it all up for us.
      """,
    codeSampleDirectory: "0101-swift-composable-architecture-tour-pt2",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 280_081_521,
      downloadUrls: .s3(
        hd1080: "0101-1080p-6d2c16fe57ef4cc78dd92e45cae0b9d8",
        hd720: "0101-720p-f0d2e542c34640c1aab8c17c61da5194",
        sd540: "0101-540p-927f38898e1c4945ad38fc9c8665d816"
      ),
      vimeoId: 416_342_062
    ),
    id: 101,
    length: 28 * 60 + 21,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1_589_173_200),
    references: [
      .theComposableArchitecture,
      .elmHomepage,
      .reduxHomepage,
    ],
    sequence: 101,
    subtitle: "Part 2",
    title: "A Tour of the Composable Architecture",
    trailerVideo: .init(
      bytesLength: 30_074_314,
      downloadUrls: .s3(
        hd1080: "0101-trailer-1080p-d82f5133ade94edaa24988c20a7f11ef",
        hd720: "0101-trailer-720p-2b95d5b4ae9d44bbbf3a02d24a3a5bd9",
        sd540: "0101-trailer-540p-766632262ab642f1b75990af2d08c4bc"
      ),
      vimeoId: 416_533_021
    ),
    transcriptBlocks: _transcriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = []

private let _transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: "Introduction",
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      And so it seems that our reducer logic is executing correctly. The `.debug`  helper is great for making sure that actions are being sent correctly and state is mutating how you expect. An even better way to verify this would be to write tests, and we'll do that soon.
      """#,
    timestamp: 5,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Collections of domain"#,
    timestamp: (0 * 60 + 41),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Before moving onto more application functionality, let's do something to clean up our reducer and view. Right now we're doing a lot of index juggling. Let's see what the Composable Architecture gives us to simplify that.
      """#,
    timestamp: (0 * 60 + 41),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Right now our action enum and reducer looks like this:
      """#,
    timestamp: (1 * 60 + 4),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum AppAction {
        case todoCheckboxTapped(index: Int)
        case todoTextFieldChanged(index: Int, text: String)
      }

      let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
        switch action {
        case let .todoCheckboxTapped(index: index):
          state.todos[index].isComplete.toggle()
          return .none

        case let .todoTextFieldChanged(index: index, text: text):
          state.todos[index].description = text
          return .none
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      As we add more and more actions to our todo row we are going to have more repetition of actions that take an index, and when handling those actions in the reducer we are going to repeatedly bind the `index` from the action and subscript into `state.todos`. What if we could write a reducer that focuses only on the domain of a single todo, and then we could somehow transform it into a reducer that works on a collection of todos?
      """#,
    timestamp: (1 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Well, the Composable Architecture absolutely supports this use case, and it’s called the `forEach` operator. What we can do is define a new domain for just the todo row, starting with the actions that can be performed:
      """#,
    timestamp: (1 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum TodoAction {
        case checkboxTapped
        case textFieldChanged(String)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Notice that we have dropped the `todo` prefix and dropped the indices. It doesn’t even know it’s going to be embedded in a collection of todos.
      """#,
    timestamp: (2 * 60 + 20),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We also need an environment to hold all of this feature’s dependencies, but right now we don’t have any dependencies so we can just use an empty struct:
      """#,
    timestamp: (2 * 60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct TodoEnvironment {}
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Then we define a reducer that operates on just a single todo and just with `TodoAction`s, which means we don’t have to do any index subscripting:
      """#,
    timestamp: (2 * 60 + 49),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, _ in
        switch action {
        case .checkboxTapped:
          state.isComplete.toggle()
          return .none

        case .textFieldChanged(let text):
          state.description = text
          return .none
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is so much clearer as to what is going on. No need to handle indices, and we can just concentrate on the bare essentials of what needs to be done for a single todo item.
      """#,
    timestamp: (3 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we adapt the app’s domain so that it works with a `TodoAction` at a particular index instead of spelling out each individual action:
      """#,
    timestamp: (3 * 60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum AppAction {
        case todo(index: Int, action: TodoAction)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Then, to transform our lowly `todoReducer` that operates on a single todo into a reducer that works on an entire collection of todos we can use the `forEach` higher-order reducer:
      """#,
    timestamp: (4 * 60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer = todoReducer.forEach(
        state: <#T##WritableKeyPath<GlobalState, MutableCollection>#>,
        action: <#T##CasePath<GlobalAction, (Comparable, TodoAction)>#>,
        environment: <#T##(GlobalEnvironment) -> TodoEnvironment#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This is a bit intense. This method has 3 arguments with some complex generics going on, and there’s even something called a `CasePath` in here. But while this seems intense, it is a pattern that repeats many times in the Composable Architecture and so soon enough filling in these 3 arguments will become second nature to you.
      """#,
    timestamp: (4 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The core idea of this function is that it wants to transform the `todoReducer` that only knows about a small piece of domain, in particular a single todo, into a reducer that knows about a much more complicated domain, in particular a whole collection of todos. In order to do this you have to hand `forEach` a transformation for each of the domain constituents: a state transformation that goes from some global state to a collection of todos, an action transformation that goes from some global action into a pair of index and local todo action, and then finally an environment transformation that turns the global environment into the local todo environment.
      """#,
    timestamp: (5 * 60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Each of these transformations come in a different flavor.
      """#,
    timestamp: (6 * 60 + 6),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - For state the transformation takes the form of a writable key path, because we want to be able to pluck out the collection from the global state, mutate any element in that collection, and then plug the whole collection back into the global state. And that is exactly what key paths can do.
      """#,
    timestamp: (6 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - For actions the transformation is a concept known as a “case path.” [Case paths](/episodes/ep87-the-case-for-case-paths-introduction) are something we discussed a few months ago on Point-Free, and we saw that they are the natural analog of key paths, but for enums instead of structs. Where key paths allow us to abstractly isolate a single property in a struct, case paths allow us to abstractly isolate a single case of an enum. It’s the perfect tool for writing generic algorithms over the shapes of enums, much like the `forEach` operator does. And so here we need a case path that somehow isolates a case in the global action that holds an index of the row we are interested in, along with a todo action.
      """#,
    timestamp: (6 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      - And then finally, for the environment the transformation is just a simple function from global environment to todo environment. We don’t need any key path or case path fanciness because its only job is to slice off the subset of dependencies that the todo reducer needs to do its job.
      """#,
    timestamp: (7 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, let’s start filling in these requirements. First, the `state` key path just needs to pluck out the `todos` field from the `AppState`
      """#,
    timestamp: (7 * 60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      todoReducer.forEach(
        state: \AppState.todos,
        action: <#T##CasePath<GlobalAction, (Comparable, TodoAction)>#>,
        environment: <#T##(GlobalEnvironment) -> TodoEnvironment#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we need an `action` case path that can extract out an index and todo action from the `AppAction`. You can write this by hand quite easily, but it is a little tedious and it’s just boilerplate, so the Composable Architecture also comes with a tool that allows you to generate this transformation value for free:
      """#,
    timestamp: (7 * 60 + 51),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      todoReducer.forEach(
        state: \AppState.todos,
        action: /AppAction.todo(index:action:),
        environment: <#T##(GlobalEnvironment) -> TodoEnvironment#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then finally we need to transform the global environment into the todo environment. Currently we don’t have any dependencies we need to pass down from the parent to the child, so we can just ignore the parent. Later, when the todo reducer gets more complicated, we may need to actually pass along dependencies here.
      """#,
    timestamp: (9 * 60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer: Reducer<AppState, AppAction, AppEnvironment> = todoReducer.indexed(
        state: \.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      While it may seem like a lot of work to actually invoke this `forEach` operator, it is actually packing a huge punch of functionality. It is taking care of all of the messy index juggling in a single place so that we don’t have to think about it at all in our reducers. And this transformation will really start to pay dividends as the `todoReducer` gets more complicated, say as the number of actions grows or as it starts needing to perform effects, because each new action or new effect would be yet another place we have to manage indices.
      """#,
    timestamp: (10 * 60 + 3),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      This code may seem like laborious “glue code”, that is, code that only connects two important pieces of code, in this case the `appReducer` and `todoReducer`. Some architectures even try to hide away code like this, typically using dynamic runtime tricks to make it work. However, getting this code to compile in the Composable Architecture is giving us some very strong guarantees that our pieces are plugging together correctly. Further, this code will be exercised when we start writing tests. So that means we will even get test coverage that we are gluing things together correctly, so we don’t think it’s burdensome to write this code, and in fact it’s good!
      """#,
    timestamp: (10 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Finally we have to update the view to use our new, nested action. The button looks like this:
      """#,
    timestamp: (11 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Button(action: { viewStore.send(.todo(index: index, action: .checkboxTapped)) }) {
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And the text field binding looks like this:
      """#,
    timestamp: (11 * 60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      TextField(
        "Untitled Todo",
        text: viewStore.binding(
          get: { $0.todos[index].description },
          send: { .todo(index: index, action: .textFieldChanged($0)) }
        )
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And this is enough to get the app building again, and if we run the preview we see that it seems to work just as it did before. It’s pretty cool that we were able to use a higher-order reducer to abstract away the idea of operating on a list of states. We could just write our reducer on a single piece of state, and then transform it to work on an array of states.
      """#,
    timestamp: (12 * 60 + 3),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But it gets even better. Because the Composable Architecture also comes with view helpers that help clean up all of this index subscripting, just as it came with helpers for the same problem in reducers.
      """#,
    timestamp: (13 * 60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Instead of doing a `ForEach` view directly, which requires us to do all this index juggling, we can use a Composable Architecture-aware version of `ForEach`, called `ForEachStore`. You just need to hand it a store whose state is a random access collection and whose action is an index and a local action. It will then invoke the `content` block for each row by handing it a store that has been scoped specifically for just that little bit of local domain:
      """#,
    timestamp: (13 * 60 + 32),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEachStore(
        self.store
      ) { todoStore in

      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Under the hood the `ForEachStore` will take care of all the index juggling, and we can just worry about display each row.
      """#,
    timestamp: (13 * 60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      In order to provide a store of this shape to the `ForEach` we need to transform it. Right now our store holds onto all of `AppState`, but we want to hand it a store that holds onto only the collection of todos. Similarly, the store also handles all of `AppAction` but we want to hand over a store that only knows about the indexed todo actions.
      """#,
    timestamp: (14 * 60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      The Composable Architecture comes with an operator that performs this transformation, and it’s called `scope`. It allows us to transform stores that operate on global domains into stores that operate on smaller, local domains. And we do this by specifying two transform functions:
      """#,
    timestamp: (14 * 60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEachStore(
        self.store.scope(
          state: <#T##(AppState) -> LocalState#>,
          action: <#T##(LocalAction) -> AppAction#>
        )
      ) { todoStore in

      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The first function describes how we want to transform the global state into local state, and that is to simply pluck out the array of `todos` from the app state:
      """#,
    timestamp: (15 * 60 + 10),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEachStore(
        self.store.scope(
          state: { $0.todos },
          action: <#T##(LocalAction) -> AppAction#>
        ),
        content: <#T##(Store<Identifiable, Action>) -> _#>
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      The second function describes how to transform the local action into the global action. Notice that it goes in the opposite direction as we did for state. It goes from local to global as opposed to global to local. This may seem strange, but it’s just how it is. In order to transform a global store to a local one we need to tell it how to embed the local actions into the global ones.
      """#,
    timestamp: (15 * 60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Next we need to use the view store, which has been scoped down to just a single todo’s domain. And in here we want to put the `HStack` that holds the button and the text field. Previously, when using a simple `ForEach`, we had direct access to the todo value so that we could easily construct the views by accessing the fields on the `Todo` model. However, that is no longer the case, we instead of one of these `todoStore`s, and we need wrap everything in a `WithViewStore` so that we can actually observe changes to this store:
      """#,
    timestamp: (16 * 60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEachStore(
        self.store.scope(state: \.todos, action: AppAction.todo(index:action:))
      ) { todoStore in
        WithViewStore(todoStore) { todoViewStore in
          HStack {
            Button(action: { todoViewStore.send(.checkboxTapped) }) {
              Image(systemName: todoViewStore.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(PlainButtonStyle())

            TextField(
              "Untitled Todo",
              text: todoViewStore.binding(
                get: \.description,
                send: TodoAction.textFieldChanged
              )
            )
          }
          .foregroundColor(todoViewStore.isComplete ? .gray : nil)
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This may seem a little intense, but notice that we are doing zero index juggling. All of the views being constructed are working with very simple domains.
      """#,
    timestamp: (18 * 60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Maybe even better would be to move the row view to its own view struct:
      """#,
    timestamp: (18 * 60 + 56),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      struct TodoView: View {
        let store: Store<Todo, TodoAction>

        var body: some View {
          WithViewStore(self.store) { viewStore in
            HStack {
              Button(action: { viewStore.send(.checkboxTapped) }) {
                Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
              }
              .buttonStyle(PlainButtonStyle())

              TextField(
                "Untitled Todo",
                text: viewStore.binding(
                  get: { $0.description },
                  send: { .textFieldChanged($0) }
                )
              )
            }
            .foregroundColor(self.store.isComplete ? .gray : nil)
          }
        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then we can pass this view’s initializer straight to `forEach`:
      """#,
    timestamp: (19 * 60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(
        store: self.store.scope(
          state: { $0.todos },
          action: { .todo(index: $0, action: $1) }
        ),
        content: { TodoView(store: $0) }
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And even better, we can convert all of this code into the point-free style, which means we get rid of all the closures and `$0`'s and just use functions directly:
      """#,
    timestamp: (20 * 60 + 24),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(
        store: self.store.scope(
          state: \.todos,
          action: AppAction.todo(index:action:)
        ),
        content: TodoView.init(store:)
      )
      …
      text: viewStore.binding(
        get: \.description,
        send: TodoAction.textFieldChanged
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      Heck, some of this even fits on one line:
      """#,
    timestamp: (21 * 60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      ForEach(
        store: self.store.scope(state: \.todos, action: AppAction.todo(index:action:)),
        content: TodoView.init(store:)
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      These two helpers, the `forEach` higher-order reducer and the `ForEachStore` view, have seriously simplified our application code.  The reducer gets to concentrate on operating on the bare minimum of domain while still being able to be transformed into something that works on a much more complicated domain, and the view gets to be split two views, one for each row of the list and one for the list itself. The Composable Architecture library has a few of these little helpers that can greatly simplify your application.
      """#,
    timestamp: (21 * 60 + 57),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Adding todos"#,
    timestamp: (22 * 60 + 43),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Well, now that are reducer and view is looking pretty simple, let’s start adding new features! To start, we can’t even add todos right now, so we should probably add that.
      """#,
    timestamp: (22 * 60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can start by adding a button in the navigation bar:
      """#,
    timestamp: (23 * 60 + 4),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .navigationBarItems(trailing: Button("Add") {})
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This needs to send an action, so we can add the action to our `AppAction` enum:
      """#,
    timestamp: (23 * 60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      enum AppAction {
        case addButtonTapped
        case todo(index: Int, action: TodoAction)
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And now we need to handle this action in our `appReducer`. Currently the `appReducer` is just expressed as the `forEach` of the `todoReducer`:
      """#,
    timestamp: (23 * 60 + 38),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer: Reducer<AppState, AppAction, AppEnvironment> = todoReducer.forEach(
        state: \.todos,
        action: /AppAction.todo(index:action:),
        environment: { _ in TodoEnvironment() }
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This doesn’t give us an opportunity to further handle any of the `AppAction`. To do this, we want to create a new reducer from scratch and combine its functionality with the `todoReducer`. The Composable Architecture comes with a wonderful little operator that does specifically this. It takes a variadic list of reducers that all operate on the same domain, and combines them into a single reducer by simply iterating over the list and running one reducer after another, and then finally merging all the effect publishers together.
      """#,
    timestamp: (23 * 60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      So, let’s use that operator to combine the `todoReducer` with a whole new reducer that we will use to layer on additional business logic:
      """#,
    timestamp: (24 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
        todoReducer.forEach(
          state: \.todos,
          action: /AppAction.todo(index:action:),
          environment: { _ in TodoEnvironment() }
        ),
        Reducer { state, action, environment in
        }
      )
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      In here we can switch on the `action` so that we can handle the new `addButtonTapped` action:
      """#,
    timestamp: (24 * 60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      Reducer { state, action, _ in
        switch action {
        case .addButtonTapped:

        case .todo(index: _, action: _):

        }
      }
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      In particular, when the “Add” button is tapped we want to insert a new todo into our array:
      """#,
    timestamp: (24 * 60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      case .addButtonTapped:
        state.todos.insert(Todo(), at: 0)
        return .none
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      This doesn’t yet compile because the `id` field of `Todo` does not have a default value, and it shouldn’t. Every time we generate a todo we should assign it a random `UUID`:
      """#,
    timestamp: (25 * 60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      case .addButtonTapped:
        state.todos.insert(Todo(id: UUID()), at: 0)
        return .none
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      We can also ignore `todo` actions.
      """#,
    timestamp: (25 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      case .todo(index: _, action: _):
        return .none
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      And then finally we need to make sure to send this action when the “Add” button is actually tapped:
      """#,
    timestamp: (25 * 60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      .navigationBarItems(trailing: Button("Add") {
        viewStore.send(.addButtonTapped)
      })
      """#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
      That gets things working, and if we run our preview we see that we can now add as many todos as we want.
      """#,
    timestamp: (25 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Writing our first test"#,
    timestamp: (26 * 60 + 7),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
      Alright, we've added a new feature, but something isn’t quite right with our reducer. We are currently plucking a random `UUID` out of thin air by calling its initializer.  To see why this is problematic, let’s try writing some tests.
      """#,
    timestamp: (26 * 60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      We first discussed testing the Composable Architecture [many months ago](/collections/composable-architecture/testing), and we discussed a few different facets. [First](/collections/composable-architecture/testing/ep82-testable-state-management-reducers), we discussed how to test the reducers in isolation. This is a natural place to start because one of the primary responsibilities of the reducer is to mutate the state when an action comes in. So to test that functionality we just need to construct a piece of state to start with, and feed that state and an action into the reducer, and then assert on the changes made to the state. And although our reducers are quite simple right now, in practice they can get quite complicated and have quite a bit of logic in them. So this kind of testing can be super powerful because it is so lightweight and allows you to easily probe all of the strange edge cases of your code.
      """#,
    timestamp: (26 * 60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But [then we kicked things up a notch](/collections/composable-architecture/testing/ep83-testable-state-management-effects) and showed how to test the second responsibility of the reducers: the side effects. We showed that after running the reducer, which returned a side effect publisher, we could then actually run the effect and capture the data it produced and then make an assertion that it produced the data we expected. This was incredibly powerful because we started getting test coverage on effects, which is typically off limits, and we could even get stronger guarantees about our business logic.
      """#,
    timestamp: (26 * 60 + 58),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      But [then we took things even further](/collections/composable-architecture/testing/ep84-testable-state-management-ergonomics). We showed how to marry the reducer testing and the effect testing into one cohesive, ergonomic package. We built an assertion helper that allowed us to describe a series of steps that the user takes in the application, and each step of the way had to describe exactly how the state was mutated and describe what events were fed back into the system from effects. We could even make exhaustive assertions about effects, such as they must all complete by the end of the assertion so that we know definitively that no other data was fed into the application that we might be missing.
      """#,
    timestamp: (27 * 60 + 27),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
      And so we are now going to use that to write some really nice tests for our application…next time!
      """#,
    timestamp: (28 * 60 + 1),
    type: .paragraph
  ),
]
