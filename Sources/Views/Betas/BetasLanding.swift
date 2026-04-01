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
      if subscriberState.isMaxSubscriber {
        MaxSubscriberHeader()
      } else {
        NonSubscriberHeader()
      }
    }
    .betasHeroBackground()
  }
}

private struct MaxSubscriberHeader: HTML {
  var body: some HTML {
    VStack(spacing: 1) {
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
    }
  }
}

private struct NonSubscriberHeader: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    LazyVGrid(columns: [.desktop: [1, 1]], alignItems: .start, verticalSpacing: 2) {
      VStack(spacing: 1) {
        BetasBadge()
        Header(2) {
          HTMLText("Beta previews")
        }
        .color(.black.dark(.white))
        Paragraph(.big) {
          """
          Get early access to the next generation of Point-Free libraries before they go public.
          """
        }
        .color(.gray300.dark(.gray800))
        .inlineStyle("padding", "0")
        Paragraph(.small) {
          """
          Point-Free Max subscribers can join private betas for projects we're actively \
          developing and help shape them before public release.
          """
        }
        .color(.gray300.dark(.gray800))
        CTAGroup {
          PFWButton(type: .primary) {
            HTMLText("Subscribe to Max")
          }
          .href(siteRouter.path(for: .pricingLanding))
        }
        .inlineStyle("padding-top", "0.5rem")
      }

      BetaAccessChecklist()
    }
  }
}

private struct BetasBadge: HTML {
  var body: some HTML {
    span {
      HTMLText("MAX EXCLUSIVE")
    }
    .inlineStyle("display", "inline-block")
    .inlineStyle("align-self", "flex-start")
    .inlineStyle("font-size", "0.7rem")
    .inlineStyle("font-weight", "700")
    .inlineStyle("letter-spacing", "0.08em")
    .inlineStyle("text-transform", "uppercase")
    .inlineStyle("padding", "0.3rem 0.7rem")
    .inlineStyle("border-radius", "999px")
    .inlineStyle("color", "#974dff")
    .inlineStyle(
      "background",
      "color-mix(in oklab, #974dff 12%, #ffffff)"
    )
    .inlineStyle(
      "background",
      "color-mix(in oklab, #974dff 20%, #0f1220)",
      media: .dark
    )
    .inlineStyle(
      "border",
      "1px solid color-mix(in oklab, #974dff 30%, rgba(15, 18, 32, 0.12))"
    )
    .inlineStyle(
      "border-color",
      "color-mix(in oklab, #974dff 30%, rgba(255, 255, 255, 0.12))",
      media: .dark
    )
  }
}

private struct BetaAccessChecklist: HTML {
  var body: some HTML {
    ChecklistModule(
      title: "What you get with beta access",
      items: [
        "Access pre-release libraries on GitHub",
        "Directly influence our APIs before public launch",
        "Join us for private office hour discussions",
        "Peek behind the curtain at how we build libraries",
        "All current and future betas included",
      ]
    ) {
      BetaProjectsList()
    }
  }
}

private struct BetaProjectsList: HTML {
  var body: some HTML {
    VStack(alignment: .leading, spacing: 0.5) {
      Header(5) {
        HTMLText("Currently in beta")
      }
      .color(.black.dark(.white))
      .inlineStyle("margin-top", "0.5rem")
      ul {
        for beta in Beta.all {
          li {
            span {}
              .inlineStyle("width", "6px")
              .inlineStyle("height", "6px")
              .inlineStyle("border-radius", "50%")
              .inlineStyle("background", "#974dff")
              .inlineStyle("flex-shrink", "0")
            HTMLText(beta.title)
          }
          .inlineStyle("display", "flex")
          .inlineStyle("align-items", "center")
          .inlineStyle("gap", "8px")
        }
      }
      .inlineStyle("margin", "0")
      .inlineStyle("padding", "0")
      .inlineStyle("list-style", "none")
      .inlineStyle("display", "grid")
      .inlineStyle("gap", "0.4rem")
      .color(.gray300.dark(.gray800))
    }
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

  var betaImage: some HTML {
    img()
      .attribute("src", beta.imageURL)
      .attribute("alt", beta.title)
      .inlineStyle("width", "100%")
      .inlineStyle("height", "auto")
      .inlineStyle("display", "block")
      .inlineStyle("border-radius", "0.75rem 0.75rem 0 0")
      .inlineStyle("border-bottom", "1px solid rgba(15, 18, 32, 0.08)")
      .inlineStyle("border-bottom-color", "rgba(255, 255, 255, 0.08)", media: .dark)
  }

  var body: some HTML {
    VStack(alignment: .leading, spacing: 0) {
      if isCollaborator {
        a {
          betaImage
        }
        .href(beta.repoURL)
      } else {
        betaImage
      }

      VStack(alignment: .leading, spacing: 0.5) {
        Header(4) {
          if isCollaborator {
            a { HTMLText(beta.title) }
              .href(beta.repoURL)
              .inlineStyle("color", "inherit")
              .inlineStyle("text-decoration", "none")
              .inlineStyle("text-decoration", "underline", pseudo: .hover)
          } else {
            HTMLText(beta.title)
          }
        }
        .color(.black.dark(.white))

        HTMLMarkdown(beta.blurb)
          .color(.gray300.dark(.gray800))
          .linkColor(.purple)

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
      a {
        HTMLRaw("&#10003; You're invited!")
      }
      .href(beta.repoURL)
      .inlineStyle("color", "rgb(24, 158, 72)")
      .inlineStyle("color", "rgb(162, 255, 200)", media: .dark)
      .inlineStyle("font-weight", "600")
      .inlineStyle("font-size", "0.95rem")
      .inlineStyle("text-decoration", "none")
      .inlineStyle("text-decoration", "underline", pseudo: .hover)
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
    isActiveSubscriber && plan == .max
  }
}
