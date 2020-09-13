import Foundation

extension Episode {
  public static let ep115_redactions_pt1 = Episode(
    alternateSlug: "redacted-swiftui-the-problem",
    blurb: """
SwiftUI has introduced the concept of “████ed views”, which gives you a really nice way to ████ the text and images from views. This is really powerful, but just because the view has been ████ed it doesn't mean the logic has also been ████ed. We show why this is problematic and why we want to fix it.
""",
    codeSampleDirectory: "0115-redacted-swiftui-pt1",
    exercises: _exercises,
    fullVideo: .init(
      bytesLength: 327899376,
      vimeoId: 452176076,
      vimeoSecret: "d9bf77945e86596dccd429e4afdee2b07e898e4f"
    ),
    id: 115,
    image: "https://i.vimeocdn.com/video/949225344.jpg",
    length: 25*60 + 49,
    permission: .free,
    publishedAt: Date(timeIntervalSince1970: 1598850000),
    references: [
      .init(
        author: nil,
        blurb: #"""
          Apple's new API for redacting content in SwiftUI.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)",
        publishedAt: nil,
        title: "redacted(reason:)"
      ),
      .init(
        author: "Federico Zanetello",
        blurb: #"""
          Federico demonstrates how you can use `RedactionReasons` to render custom redactions differently than the standard API.
          """#,
        link: "https://fivestars.blog/code/redacted-custom-effects.html",
        publishedAt: referenceDateFormatter.date(from: "2020-07-28"),
        title: "Creating custom .redacted effects"
      ),
      .init(
        author: nil,
        blurb: #"""
          "Separation of Concerns" is a design pattern that is expressed often but is a very broad guideline, and not something that can be rigorously applied.
          """#,
        link: "https://en.wikipedia.org/wiki/Separation_of_concerns",
        publishedAt: nil,
        title: "Separation of Concerns"
      ),
      .init(
        author: "Curt Clifton, Luca Bernadi, and Raj Ramamurthy",
        blurb: #"""
          This WWDC 2020 session covers the various APIs SwiftUI provides to drive your views with your data models using bindings, `@State`, `@ObservedObject`, and the newly-introduced `@StateObject`.
          """#,
        link: "https://developer.apple.com/videos/play/wwdc2020/10040/",
        publishedAt: referenceDateFormatter.date(from: "2020-06-27"),
        title: "Data Essentials in SwiftUI"
      ),
      .init(
        author: nil,
        blurb: #"""
          Apple's guidance for managing a SwiftUI application's data model using bindings, `@State`, `@ObservedObject`, and the newly-introduced `@StateObject`.
          """#,
        link: "https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app",
        publishedAt: nil,
        title: "Managing Model Data in Your App"
      ),
      .init(
        author: "Chris Eidhof, et al.",
        blurb: #"""
          A Twitter thread between the community and several Apple engineers about when to use `@StateObject` and when to use `@ObservedObject`. Nick Lockwood [succinctly explains](https://twitter.com/nicklockwood/status/1280133214489710596) that `@StateObject` is persisted across view instantiations, while SwiftUI engineer Luca Bernardi gives both [a general guideline](https://twitter.com/luka_bernardi/status/1280224429637681152) on when to use which, while [expanding](https://twitter.com/luka_bernardi/status/1279124141837185025) that it should be valid to instantiate a `StateObject` with data it depends on.
          """#,
        link: "https://twitter.com/chriseidhof/status/1280085055021383681",
        publishedAt: referenceDateFormatter.date(from: "2020-07-06"),
        title: "StateObject vs. ObservedObject"
      ),
      .init(
        author: "Joe Groff",
        blurb: #"""
          Swift engineer Joe Groff explains how `@State` should only be initialized where the property is declared and that parent views should not pass data to child views to be handed to any internal `@State`.
          """#,
        link: "https://twitter.com/jckarter/status/1270135428394315776",
        publishedAt: referenceDateFormatter.date(from: "2020-07-06"),
        title: "Initializing @State from a parent"
      ),
    ],
    sequence: 115,
    subtitle: "The Problem",
    title: "█████ed SwiftUI",
    trailerVideo: .init(
      bytesLength: 49_832_966,
      vimeoId: 453129382,
      vimeoSecret: "3764f3dc3994fd29895a4812e5e45244d6cb1f99" 
    ),
    transcriptBlocks: _transcriptBlocks
  )
}

private let _exercises: [Episode.Exercise] = [
  // TODO
]

private let _transcriptBlocks: [Episode.TranscriptBlock] = [
  Episode.TranscriptBlock(
    content: #"Introduction"#,
    timestamp: 5,
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
Today we are going to look at a brand new feature of SwiftUI and show how the Composable Architecture can enhance it. This is a little different from some of our other series of episodes where we dive into general principles that are broadly applicable. Instead we are going to focus on something very specific, but along the way some really cool things that we never even considered when we first began working on the architecture.
"""#,
    timestamp: 5,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We are going to discuss what the Composable Architecture has to say about a brand new feature of iOS 14 and SwiftUI. [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) is a library we built up from first principles in episodes over the past year, and then 4 months ago we finally open sourced it. We haven’t really talked much about the architecture since open sourcing, but then something happened recently that we just had to discuss.
"""#,
    timestamp: (0*60 + 34),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
In a recent beta release we were all given access to a brand new API that allows you to redact an entire view, so that text views are blocked out by grey boxes, and even images are blocked out. It’s pretty amazing to see, and the power of SwiftUI is really starting to show that things that were previously hard to even imagine are now possible.
"""#,
    timestamp: (0*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And there are lots of applications of this trick. We can use it while loading data so that we can show the user what the UI will look like once everything finishes, and while they wait they can just see an outline of shapes. It can also be interesting to use this trick to focus the user’s attention on a particular part of the screen. You could imagine an onboarding experience that redacts everything on the screen except one small part so that you can teach the person how to use that part of your application.
"""#,
    timestamp: (1*60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Now, although this is a cool trick, if you use it naively you will have some really weird UI experiences. Just because the visual UI is redacted doesn’t mean that the logic of the view is redacted. For example, it’s possible for the UI to be redacted but for all of your buttons, UI controls, and gestures to be active, which means the user can still do things with it even though maybe they shouldn’t.
"""#,
    timestamp: (1*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And so what we want to show is that features built with the Composable Architecture can take advantage of this new redaction feature in a really unique way, and replicating this technique in vanilla SwiftUI is quite difficult, if not impossible. We will show that you can selectively disable all of the logic for a particular part of your application, and that opens up all types of cool possibilities.
"""#,
    timestamp: (2*60 + 18),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We’ll show this by analyzing a new sample application that we have built in both a vanilla SwiftUI way and a Composable Architecture way so that we can compare the two approaches.
"""#,
    timestamp: (2*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"An articles app with a loading screen"#,
    timestamp: (3*60 + 6),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
We are going to take a look at a simple screen that displays some articles. We aren’t going to build this feature from scratch as we have done many times in the past with other screens, but instead we are going to investigate how we can improve the UX of this screen using a fancy new feature of SwiftUI.
"""#,
    timestamp: (3*60 + 6),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
When we load up this screen we see a loading indicator with some placeholder articles, and after about 4 seconds some articles appear. We are purposely inserting a long wait in fetching the articles so that we can show what the loading experience is like.
"""#,
    timestamp: (3*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Once articles are loaded you can finally start interacting with the application. You can star an article to favorite it, or you can tap the book icon to mark it for read-later, and presumably this would save the article for offline reading. And finally you can tap the last icon to hide this article, which currently doesn’t do anything, and we’ll explain why in a moment.
"""#,
    timestamp: (3*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We will start with a version of this application that does not have those placeholder articles in the loader screen to see how we can add them from scratch.
"""#,
    timestamp: (3*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Let’s take a look at how the feature is currently built, and see what we can do to add this loading placeholder feature. Right now the project has a `Shared.swift` file with some base models, and we’ve put it in this file because soon we will share this code with a version of this feature built in the Composable Architecture.
"""#,
    timestamp: (4*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The file holds the model of an article:
"""#,
    timestamp: (4*60 + 39),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
struct Article: Equatable, Identifiable {
  var blurb: String
  var date: Date
  let id: UUID
  var isHidden = false
  var isFavorite = false
  var title: String
  var willReadLater = false
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
As well as an array of placeholder values that we want to render while we are loading:
"""#,
    timestamp: (4*60 + 43),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
let placeholderArticles = (0...10).map { _ in
  Article(
    blurb: String(repeating: " ", count: .random(in: 50...100)),
    date: .init(),
    id: .init(),
    isFavorite: Bool.random(),
    title: String(repeating: " ", count: .random(in: 10...30)),
    willReadLater: Bool.random()
  )
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And then also an array of “live” articles that we will show when loading finishes:
"""#,
    timestamp: (5*60 + 2),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
let liveArticles = [
  ...
]
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Then we’ve got the view model that powers this application. It’s quite simple right now:
"""#,
    timestamp: (5*60 + 8),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
class AppViewModel: ObservableObject {
  @Published var articles: [Article] = []
  @Published var isLoading = false
  @Published var readingArticle: Article?

  init() {
    self.isLoading = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
      self.articles = liveArticles
      self.isLoading = false
    }
  }

  func tapped(article: Article) {
    self.readingArticle = article
  }
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
It tries fetching the live articles right when it is created, but it simulates that taking a long time by waiting 4 seconds before delivering the results. It also holds some state that indicates what article is currently being read, which we can use to drive the sheet that shows the article.
"""#,
    timestamp: (5*60 + 23),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Then we’ve got the main view that renders our application:
"""#,
    timestamp: (5*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
struct VanillaArticlesView: View {
  @ObservedObject private var viewModel = AppViewModel()

  var body: some View {
    NavigationView {
      List {
        if self.viewModel.isLoading {
          ActivityIndicator()
            .frame(maxWidth: .infinity)
            .padding()
        }

        ForEach(self.viewModel.articles.filter { !$0.isHidden }) { article in
          Button(action: { self.viewModel.tapped(article: article) }) {
            ArticleRowView(article: article)
          }
        }
      }
      .sheet(item: self.$viewModel.readingArticle) { article in
        NavigationView {
          ArticleDetailView(article: article)
            .navigationTitle(article.title)
        }
      }
      .navigationTitle("Articles")
    }
  }
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This is all pretty straightforward stuff, but there is one tricky thing we are doing. We are using a new feature of SwiftUI in this line here:
"""#,
    timestamp: (6*60 + 21),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
ArticleRowView(article: article)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This makes it seem as if we creating the `ArticleRowView` from just a static piece of data, but secretly in that view we are actually instantiating a whole new view model:
"""#,
    timestamp: (6*60 + 30),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
private struct ArticleRowView: View {
  @StateObject var viewModel: ArticleViewModel

  ...
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This `@StateObject` property wrapper is new, and it allows us to create a view model from within a view. That may not seem like anything special, but recall that SwiftUI recreates these little view structs many many times. It could do it dozens or hundreds of times. And that’s supposed to be ok because these structs don’t represent actual UI, but rather a description of UI that will later be rendered. That’s the real power of SwiftUI, the fact that it has such a lightweight description of view hierarchies.
"""#,
    timestamp: (6*60 + 55),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But if we are recreating this row potentially dozens, or hundreds, of times, doesn’t that mean we’ll also create the view model many times? Well, that’s where the `@StateObject` comes into play. It will guarantee that the view model is only created a single time for this view. This is very similar to how `@State` works, because if we did something like:
"""#,
    timestamp: (7*60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
@State var value = 1
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Then this value is initialized and set to 1 only the first time the view is created. Subsequent creations of this view will share whatever value the previous views had.
"""#,
    timestamp: (7*60 + 48),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We can even see how invoking `StateObject` initializer does not necessarily execute the code creating the view model we pass to it, because secretly it takes an autoclosure under the hood:
"""#,
    timestamp: (8*60 + 1),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
@propertyWrapper
struct StateObject<ObjectType>: DynamicProperty
where ObjectType: ObservableObject {
  ...
  init(wrappedValue thunk: @autoclosure @escaping () -> ObjectType)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This allows SwiftUI to call this closure the first time it needs to and keep the value around in its system for future view renders.
"""#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Now its worth saying that there’s actually quite a bit conflicting information out there on whether or not this is a correct way of initializing a `StateObject`. It does have some caveats, but it also certainly works for our use case right now. We have some references on the episode page to help you research this a bit yourself, and we will have some episodes in the future that goes deep into this topic.
"""#,
    timestamp: (8*60 + 22),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But caveats aside, this is cool and all, but what exactly is the `ArticleViewModel`? It encapsulates the functionality for a row in this list, which means it handles favoriting an article, marking one to be read later, and hiding an article:
"""#,
    timestamp: (8*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
class ArticleViewModel: ObservableObject {
  @Published var article: Article

  init(article: Article) {
    self.article = article
  }

  func favorite() {
    // Make API request to favorite article on server
    self.article.isFavorite.toggle()
  }

  func readLater() {
    // Make API request to add article to read later list
    self.article.willReadLater.toggle()
  }

  func hide() {
    // Make API request to hide article so we never see it again
    self.article.isHidden.toggle()
  }
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
Right now we are just updating state, but you could imagine that in the future we’d want to do API requests from these methods to keep things in sync with a server, and so things could be quite a bit more complicated.
"""#,
    timestamp: (9*60 + 13),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
And this is the view that renders the article row:
"""#,
    timestamp: (9*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
private struct ArticleRowView: View {
  @StateObject var viewModel: ArticleViewModel

  init(article: Article) {
    self._viewModel = StateObject(wrappedValue: ArticleViewModel(article: article))
  }

  var body: some View {
    HStack(alignment: .top) {
      Image("")
        .frame(width: 80, height: 80)
        .background(Color.init(white: 0.9))
        .padding([.trailing])

      VStack(alignment: .leading) {
        Text(self.viewModel.article.title)
          .font(.title)

        Text(articleDateFormatter.string(from: self.viewModel.article.date))
          .bold()

        Text(self.viewModel.article.blurb)
          .padding(.top, 6)

        HStack {
          Spacer()

          Button(
            action: {
              self.viewModel.favorite()
            }) {
            Image(systemName: "star.fill")
          }
          .buttonStyle(PlainButtonStyle())
          .foregroundColor(self.viewModel.article.isFavorite ? .red : .blue)
          .padding()

          Button(
            action: {
              self.viewModel.readLater()
            }) {
            Image(systemName: "book.fill")
          }
          .buttonStyle(PlainButtonStyle())
          .foregroundColor(self.viewModel.article.willReadLater ? .yellow : .blue)
          .padding()

          Button(
            action: {
              self.viewModel.hide()
            }) {
            Image(systemName: "eye.slash.fill")
          }
          .buttonStyle(PlainButtonStyle())
          .foregroundColor(.blue)
          .padding()
        }
      }
    }
    .padding([.top, .bottom])
    .buttonStyle(PlainButtonStyle())
  }
}

fileprivate struct ArticleDetailView: View {
  let article: Article

  var body: some View {
    Text(article.blurb)
  }
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
It’s a pretty straightforward view, mostly just reads data from the view model to render the hierarchy, and sends user actions to the view model to be processed.
"""#,
    timestamp: nil,
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
One thing you’ll notice is that we do properly handle the logic for hiding the article in the view model, yet when we tap the button the article does not hide. This is because we are updating the state as far as the `ArticleViewModel` is concerned, but it’s the `ArticlesViewModel` that drives the list of articles. And that state is not being updated. We need some way to have this child view model communicate to the parent. This is the problem that we alluded to a moment ago. It is possible to fix this situation, but we plan on discussing this topic in some dedicated episodes in the future, so we won’t dive any further into it.
"""#,
    timestamp: (10*60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Redacting UI for a loading screen"#,
    timestamp: (11*60 + 14),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
So now that we understand how the application is built, let’s add the feature that shows some placeholder articles while we are loading. All the pieces are already here and it doesn’t take much work to finish it off.
"""#,
    timestamp: (11*60 + 14),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
For example, we already have an `isLoading`  boolean in the view model that tells us when we are currently fetching articles. We can use this boolean to drive whether or not we redact content in this list:
"""#,
    timestamp: (11*60 + 33),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
ForEach {
  ...
}
.redacted(reason: <#T##RedactionReasons#>)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This method takes a `RedactionReasons` value, which is an option set that allows you to specify zero or more reasons for redaction. To create a redaction reason you can provide a raw integer value:
"""#,
    timestamp: (11*60 + 52),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
.redacted(reason: .init(rawValue: 1))
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
This number 1 doesn’t really describe why exactly we are redacting, so better would be to create a dedicate value of this type, which can be held as a static:
"""#,
    timestamp: (12*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
extension RedactionReasons {
  static let loading = RedactionReasons(rawValue: 1)
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And then we can do:
"""#,
    timestamp: (12*60 + 44),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
.redacted(reason: .loading)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And sometimes you may not even want to provide a custom reason. SwiftUI comes with a reason out of the box, which we can use like this:
"""#,
    timestamp: (12*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
.redacted(reason: .placeholder)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
The main reason to create custom reasons is if you have logic inside your views that should change based on the type of reason being used. For example, you can use the reason to render the redaction differently, like using a blur instead of a solid grey rectangle.
"""#,
    timestamp: (13*60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But for right now the `placeholder` reason is sufficient for our use cases, and so we can use the `isLoading` boolean to drive the redaction reasons:
"""#,
    timestamp: (13*60 + 35),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
.redacted(reason: self.viewModel.isLoading ? .placeholder : [])
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
So that’s all it takes to redact content in the list while loading, but of course there is no content in the list while loading. So we need to update our `ForEach` to use some placeholder articles while loading:
"""#,
    timestamp: (13*60 + 59),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
ForEach(
  self.viewModel.isLoading
    ? placeholderArticles
    : self.viewModel.articles.filter { !$0.isHidden }
) { article in
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And just like that we are showing placeholder articles while loading. This is pretty amazing. We literally changed only 2 lines of code and were able to improve the user experience for this feature. SwiftUI is really enabling a whole new level of application development that was previously much much more difficult.
"""#,
    timestamp: (14*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Redacting logic"#,
    timestamp: (16*60 + 0),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
However, even though it’s easy to get the basics of the loading placeholders in place, it takes more work to get it right. Because right now there are few things that are a little strange with the placeholders.
"""#,
    timestamp: (16*60 + 0),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
For example, while articles are loading I can tap on one of the placeholder articles and it brings up a sheet. That’s not ideal at all. Also all of the icon buttons are still tappable, and we can even see their logic is executing because the colors are changing. Recall that right now the logic for these buttons is simple boolean toggling, but really we should be firing off API requests and doing real work in those endpoints. All of that logic would be executing for these fake, placeholder articles, and that seems really bad.
"""#,
    timestamp: (16*60 + 47),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
So let’s fix this. SwiftUI gives us a tool to help our views know when they are redacted. We can add an environment variable to our view, which holds the current set of reasons, if any, of why the view is being redacted:
"""#,
    timestamp: (17*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
private struct ArticleRowView: View {
  @StateObject var viewModel: ArticleViewModel
  @Environment(\.redactionReasons) var redactionReasons

  ...
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And then we can inspect this value whenever the user does something in the UI, and if it contains any reasons we can short circuit that logic so that it is never executed:
"""#,
    timestamp: (18*60 + 1),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Button(
  action: {
    guard self.redactionReasons.isEmpty else { return }
    self.viewModel.favorite()
  }) {
  ...
}

Button(
  action: {
    guard self.redactionReasons.isEmpty else { return }
    self.viewModel.readLater()
  }) {
  ...
}

Button(
  action: {
    guard self.redactionReasons.isEmpty else { return }
    self.viewModel.hide()
  }) {
  ...
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
So that takes care of the icon buttons in the article row, but we also have the button for the whole article row itself. And that needs to be done in the `ArticlesView`. In this view we don’t have any redaction reasons, so we don’t need to introduce an environment value. Instead we can just access the `viewStore`'s `isLoading` boolean just like we’ve done before:
"""#,
    timestamp: (18*60 + 25),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Button(
  action: {
    guard !self.viewModel.isLoading else { return }
    self.viewModel.tapped(article: article)
  }) {
  ...
}
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
And now the view is a bit friendlier to use. We are free to tap around while it’s loading without fear of executing some business logic or firing off API requests.
"""#,
    timestamp: (19*60 + 15),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But this isn’t how we would want to craft our code in a real application. We have now littered random bits of logic all over our views to check for this `redactionReasons` value, which has complicated the essence of what this view is responsible for. Also, as we add more features to this application we will have to always remember to redact its logic or we run the risk of accidentally executing logic when placeholders are visible. And this is definitely a real problem to worry about because 6 months from now you may not remember all the ins and outs of how loading placeholders work, or perhaps one of your colleagues will want to make changes to this view, and as it stands right now its a bit of a mine field of potential gotchas.
"""#,
    timestamp: (19*60 + 26),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
There is one really simple, albeit naive, thing we could do to remedy this current situation in one fell swoop: we could disable the entire list when data is loading:
"""#,
    timestamp: (20*60 + 7),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
ForEach {
  ...
}
.disabled(self.viewModel.isLoading)
"""#,
    timestamp: nil,
    type: .code(lang: .swift)
  ),
  Episode.TranscriptBlock(
    content: #"""
So this certainly does the job. We can even comment out all that logic that checks for redaction reasons all of the place and we’ll see that it still behaves basically how we want.
"""#,
    timestamp: (20*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
However, there’s something strange about doing things this way:
"""#,
    timestamp: (20*60 + 50),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
- Disabling the list means that all the colors have gotten lighter. The grays are lighter, and even the icons are lighter. Maybe this isn’t a big deal to you, but it will be the reality of using this technique: all of the UI will get dimmer and less vibrant.
"""#,
    timestamp: (20*60 + 53),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
- Disabling has also changed the semantic meaning of this view. It’s not really that this view is disabled, it’s just that we want to put in a static, inert version of the UI. Applying a disabled attribute might be a little too heavy handed for this situation, and could impact the user experience in ways that we are not aware of right now, such as accessibility.
"""#,
    timestamp: (21*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
- Disabling may not disable everything you expect it to. It certainly disables things like buttons, text fields and other UI controls, but other events will still fire. For example, if we had an `.onAppear` modifier in this list so that we could fire off some analytics or an API request, that logic would still execute just like normal, even if the whole view is disabled.
"""#,
    timestamp: (21*60 + 37),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
- Also, once you disable a view hierarchy there is no way to selectively re-enable parts of the inside of the view. This is possible with redactions. We haven’t covered it yet, but soon we will see that within a redacted view we can unredact certain parts to make it visible to the user again. This impedance mismatch between these two APIs is really pointing at the fact that disabling UI is not a great way for handling this functionality. There may be times that we want to unredact a little bit of the view, and inside that view we have a button. We will have no way of re-enabling it and so it will stay stuck as disabled. And what if that button did something important, like canceled the inflight request? It’s definitely not acceptable to just blanket disable everything.
"""#,
    timestamp: (22*60 + 1),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
So what we are seeing is that using `disabled` to handle this kind of placeholder functionality is not great, and so when building an application in the vanilla SwiftUI approach we may need to sprinkle bits of logic all around our view to selectively disable parts of its logic.
"""#,
    timestamp: (22*60 + 45),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
The main reason this is happening is that our view is inextricably linked with its logic. We have this view model object that is just plopped right down into this view, and whatever happens in the view is going to always be relayed back to the view model. This is a very tight coupling and doesn’t give us much freedom to adapt.
"""#,
    timestamp: (23*60 + 9),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We feel that although SwiftUI views are an amazing technology, they are ripe for abuse in this regard. There is a phrase that people in the programming community that is very popular and seen as a kind of "north star" for software development, and it says that we should try to “separate concerns” in our applications. Now of course there is no precise definition of what “separate” and “concerns” means. Does separate mean put code in separate files, or does it mean something deeper? And can an entire screen be one concern, or must it be composed of many concerns, and how granular should we get? For this reason we think the “separation of concerns” adage is a very broad guideline, and not something that can be rigorously applied.
"""#,
    timestamp: (23*60 + 31),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
But, having said that, we think that SwiftUI views, when built in this kind of straightforward manner, are some of the biggest offenders of concerns not being separated. Views tend to accumulate lots of logic, especially in action closures on various UI controls, and there’s really no way in which we can say that the view and its view model are separate, isolated units.
"""#,
    timestamp: (24*60 + 17),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"Next time: Redacting in the Composable Architecture"#,
    timestamp: (24*60 + 46),
    type: .title
  ),
  Episode.TranscriptBlock(
    content: #"""
Well, we want to show that the Composable Architecture really embodies the spirit of “separation of concerns”, and this will lead us to some amazing results. Not only does it completely separate the logic of your feature from its view, but we are also free to plug in placeholder forms of logic, and this is the key that is missing from vanilla SwiftUI.
"""#,
    timestamp: (24*60 + 46),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
We will do this by looking at another version of this articles feature, except this time built using the Composable Architecture. We will see that not only is the Composable Architecture version of this application not that much more code than the vanilla SwiftUI version, but that it leaves us open to some really interesting possibilities when it comes to redacting parts of our views.
"""#,
    timestamp: (25*60 + 8),
    type: .paragraph
  ),
  Episode.TranscriptBlock(
    content: #"""
Let’s start by looking at what this articles feature looks like when built with the Composable Architecture. There really isn’t that big of a difference between it and the vanilla SwiftUI version, other than the core domain has been moved to value types and all of the logic takes place in a reducer function rather than a view model class.
"""#,
    timestamp: (25*60 + 29),
    type: .paragraph
  ),
]
