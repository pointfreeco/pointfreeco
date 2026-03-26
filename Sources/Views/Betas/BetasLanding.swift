import Dependencies
import Html
import Models
import PointFreeDependencies
import StyleguideV2

public struct BetasLanding: HTML {
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  public init() {}

  public var body: some HTML {
    BetasHeader()
    BetasList()
    if !subscriberState.isActiveSubscriber {
      BetasCTA()
    }
  }
}

private struct BetasHeader: HTML {
  var body: some HTML {
    PageModule(theme: .content) {
      VStack(spacing: 1) {
        Header(2) {
          HTMLText("Max previews")
        }
        .color(.black.dark(.white))
        Paragraph(.big) {
          """
          Get early access to the next generation of Point-Free libraries. \
          As a Point-Free Max subscriber, you can join private betas for projects \
          we're actively developing and help shape them before they go public.
          """
        }
        .color(.gray300.dark(.gray800))
        .inlineStyle("padding", "0")
      }
    }
    .betasHeroBackground()
  }
}

private struct BetasList: HTML {
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(theme: .content) {
      VStack(spacing: 2) {
        Header(3) {
          HTMLText("Open Betas")
        }
        .color(.black.dark(.white))

        LazyVGrid(
          columns: [.desktop: [1, 1], .mobile: [1]],
          horizontalSpacing: 2,
          verticalSpacing: 2
        ) {
          BetaCard(
            imageSrc:
              "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/tca-2-beta/public",
            title: "ComposableArchitecture 2.0",
            blurb: """
              A ground-up reimagining of the Composable Architecture. Simpler, faster, \
              and more flexible, while keeping the same principles of testability and \
              composability that make TCA great.
              """,
            isMaxSubscriber: subscriberState.isMaxSubscriber
          )
          BetaCard(
            imageSrc:
              "https://imagedelivery.net/6_EEbfI_pxOPJCtc6OUKCg/debug-snapshots-beta/public",
            title: "DebugSnapshots",
            blurb: """
              A tool for making it possible to test non-equatable types and reference types. \
              Capture and compare snapshots of your app's state in a human-readable format, \
              making it easy to catch unexpected changes.
              """,
            isMaxSubscriber: subscriberState.isMaxSubscriber
          )
        }
      }
    }
    Divider(size: 100)
  }
}

private struct BetaCard: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let imageSrc: String
  let title: String
  let blurb: String
  let isMaxSubscriber: Bool

  var body: some HTML {
    VStack(alignment: .leading, spacing: 0) {
      img()
        .attribute("src", imageSrc)
        .attribute("alt", title)
        .inlineStyle("width", "100%")
        .inlineStyle("height", "200px")
        .inlineStyle("object-fit", "cover")
        .inlineStyle("border-radius", "0.75rem 0.75rem 0 0")
        .inlineStyle("border-bottom", "1px solid rgba(15, 18, 32, 0.08)")
        .inlineStyle("border-bottom-color", "rgba(255, 255, 255, 0.08)", media: .dark)

      VStack(alignment: .leading, spacing: 0.5) {
        Header(4) {
          HTMLText(title)
        }
        .color(.black.dark(.white))

        Paragraph {
          HTMLText(blurb)
        }
        .color(.gray300.dark(.gray800))

        if isMaxSubscriber {
          PFWButton(type: .primary) {
            HTMLText("Join beta")
          }
          .inlineStyle("margin-top", "1rem")
        } else {
          PFWButton(type: .secondary) {
            HTMLText("Subscribe to Point-Free Max")
          }
          .href(siteRouter.path(for: .pricingLanding))
          .inlineStyle("margin-top", "1rem")
        }
      }
      .inlineStyle("padding", "1.5rem")
    }
    .inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
    .inlineStyle("border-color", "rgba(255, 255, 255, 0.12)", media: .dark)
    .inlineStyle("border-radius", "1rem")
    .inlineStyle("background", "#fcfcfc")
    .inlineStyle("background", "#0f1220", media: .dark)
    .inlineStyle("overflow", "hidden")
  }
}

private struct BetasCTA: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(theme: .content) {
      HStack(alignment: .center, spacing: 2) {
        VStack {
          Header(3) {
            HTMLText("Get early access.")
          }
          .color(.black.dark(.white))
          Paragraph(.big) {
            """
            Become a Point-Free Max member to join private betas and help shape the future \
            of our open source libraries.
            """
          }
          .color(.gray300.dark(.gray800))
        }
        Spacer()
        VStack {
          PFWButton(type: .primary) {
            HTMLText("Subscribe to Max")
          }
          .href(siteRouter.path(for: .pricingLanding))
          .inlineStyle("margin-right", "auto")
        }
      }
    }
    .betasFooterBackground()
  }
}

extension HTML {
  fileprivate func betasHeroBackground() -> some HTML {
    inlineStyle(
      "background",
      """
      radial-gradient(900px 700px at 20% 20%, rgba(151, 77, 255, 0.14), transparent 55%),
      radial-gradient(900px 700px at 80% 70%, rgba(76, 204, 255, 0.12), transparent 55%),
      linear-gradient(180deg, #f6f7fb, #eef1f7)
      """
    )
    .inlineStyle(
      "background",
      """
      radial-gradient(900px 700px at 20% 20%, rgba(151, 77, 255, 0.14), transparent 55%),
      radial-gradient(900px 700px at 80% 70%, rgba(76, 204, 255, 0.12), transparent 55%),
      linear-gradient(180deg, #07080b, #0b0d10)
      """,
      media: .dark
    )
  }
  fileprivate func betasFooterBackground() -> some HTML {
    inlineStyle(
      "background",
      """
      linear-gradient(
        180deg,
        color-mix(in oklab, #ffffff 100%, transparent) 0%,
        color-mix(in oklab, #974dff 20%, #ffffff) 100%
      )
      """
    )
    .inlineStyle(
      "background",
      """
      linear-gradient(
        180deg,
        color-mix(in oklab, #000000 100%, transparent) 0%,
        color-mix(in oklab, #974dff 30%, #000000) 100%
      )
      """,
      media: .dark
    )
  }
}

extension SubscriberState {
  var isMaxSubscriber: Bool {
    // TODO: Implement actual Max plan check
    isActiveSubscriber
  }
}
