import Dependencies
import StyleguideV2

public struct Collections: HTML {
  @Dependency(\.collections) var collections

  public init() {}

  public var body: some HTML {
    PageHeader {
      "Collections"
    } blurb: {
      "We contextualize broad themes into episode collections."
    }

    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1, 1]]) {
        for (index, collection) in collections.enumerated() {
          CollectionCard(collection, index: index)
        }
      }
    }

    CallToAction()
  }
}

private struct CallToAction: HTML {
  @Dependency(\.currentUser) var currentUser
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    if currentUser == nil {
      GetStartedModule(style: .gradient)
    } else if subscriberState.isNonSubscriber {
      UpgradeModule()
    }
  }
}
