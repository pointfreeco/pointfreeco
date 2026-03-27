import Dependencies
import Html
import Models
import PointFreeDependencies
import StyleguideV2

public struct BetasLanding: HTML {
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  public var collaboratorStatuses: [String: Bool]

  public init(collaboratorStatuses: [String: Bool] = [:]) {
    self.collaboratorStatuses = collaboratorStatuses
  }

  public var body: some HTML {
    BetasHeader()
    BetasList(collaboratorStatuses: collaboratorStatuses)
    if !subscriberState.isActiveSubscriber {
      Divider(size: 100)
      BetasCTA()
    }
  }
}

private struct BetasHeader: HTML {
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(theme: .content) {
      VStack(spacing: 1) {
        if subscriberState.isMaxSubscriber {
          Header(2) {
            HTMLText("Your betas")
          }
          .color(.black.dark(.white))
          Paragraph(.big) {
            """
            You have early access to the next generation of Point-Free libraries. \
            Join any of the private betas below to help shape them before they go public.
            """
          }
          .color(.gray300.dark(.gray800))
          .inlineStyle("padding", "0")
        } else {
          Header(2) {
            HTMLText("Beta previews")
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
          CTAGroup {
            PFWButton(type: .primary) {
              HTMLText("Subscribe to Max")
            }
            .href(siteRouter.path(for: .pricingLanding))
          }
          .inlineStyle("padding-top", "0.5rem")
        }
      }
    }
    .betasHeroBackground()
  }
}

private struct BetasList: HTML {
  let collaboratorStatuses: [String: Bool]

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
          for beta in Beta.all {
            BetaCard(beta: beta, isCollaborator: collaboratorStatuses[beta.repo] ?? false)
          }
        }
      }
    }
  }
}

private struct BetaCard: HTML {
  @Dependency(\.subscriberState) var subscriberState
  @Dependency(\.siteRouter) var siteRouter

  let beta: Beta
  let isCollaborator: Bool

  var body: some HTML {
    VStack(alignment: .leading, spacing: 0) {
      img()
        .attribute("src", beta.imageSrc)
        .attribute("alt", beta.title)
        .inlineStyle("width", "100%")
        .inlineStyle("height", "200px")
        .inlineStyle("object-fit", "cover")
        .inlineStyle("border-radius", "0.75rem 0.75rem 0 0")
        .inlineStyle("border-bottom", "1px solid rgba(15, 18, 32, 0.08)")
        .inlineStyle("border-bottom-color", "rgba(255, 255, 255, 0.08)", media: .dark)

      VStack(alignment: .leading, spacing: 0.5) {
        Header(4) {
          HTMLText(beta.title)
        }
        .color(.black.dark(.white))

        Paragraph {
          HTMLText(beta.blurb)
        }
        .color(.gray300.dark(.gray800))

        if subscriberState.isMaxSubscriber {
          BetaJoinButton(beta: beta, isCollaborator: isCollaborator)
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

private struct BetaJoinButton: HTML {
  @Dependency(\.siteRouter) var siteRouter

  let beta: Beta
  let isCollaborator: Bool

  var body: some HTML {
    if isCollaborator {
      span {
        HTMLRaw("&#10003; You're invited!")
      }
      .inlineStyle("color", "rgb(24, 158, 72)")
      .inlineStyle("color", "rgb(162, 255, 200)", media: .dark)
      .inlineStyle("font-weight", "600")
      .inlineStyle("font-size", "0.95rem")
    } else {
      form {
        PFWButton(type: .primary, tag: button) {
          HTMLText("Join beta")
        }
        .attribute("type", "submit")
      }
      .attribute("action", siteRouter.path(for: .betas(.join(repo: beta.repo))))
      .attribute("method", "post")
    }
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
  public var isMaxSubscriber: Bool {
    // TODO: Implement actual Max plan check
    isActiveSubscriber
  }
}
