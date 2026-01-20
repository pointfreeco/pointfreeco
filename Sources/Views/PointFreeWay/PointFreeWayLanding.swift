import Css
import Dependencies
import FunctionalCss
import Html
import HtmlCssSupport
import Models
import PointFreeDependencies
import Prelude
import Styleguide
import StyleguideV2

public struct PointFreeWayLanding: HTML {
  @Dependency(\.subscriberState) var subscriberState

  public init() {}

  public var body: some HTML {
    PointFreeWayHeader()
    WhatIsThePointFreeWay()
    BuildInThePointFreeStyle()
    HandCrafted()
    HowAccessWorks()
    if !subscriberState.isActiveSubscriber {
      NotReadyToSubscribe()
      BuildSoftwareThatLasts()
    }
  }
}

struct PointFreeWayHeader: HTML {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        VStack(spacing: 1) {
          Header(2) {
            HTMLRaw("The Point&#8209;Free Way")
          }
          .titleColor()
          Paragraph(.big) {
            "Expert-crafted AI skill documents for building long-lasting Swift applications."
          }
          .contentColor()
          .inlineStyle("padding", "0")
          Paragraph(.small) {
            HTMLRaw(
              """
              Design, test, and evolve applications using the same principles, libraries, 
              and techniques we use every day at Point&#8209;Free.
              """
            )
          }
          .contentColor()
          Divider(alignment: .left, size: 30)
            .inlineStyle("margin-top", "1rem")
            .inlineStyle("margin-bottom", "1rem")
          if subscriberState.isActiveSubscriber {
            AccessUnlocked()
          } else {
            CTAGroup {
              PFWButton(type: .primary) {
                HTMLText("Subscribe to unlock")
              }
              .href(siteRouter.path(for: .pricingLanding))
              PFWButton {
                HTMLText("Explore Point-Free")
              }
              .href(siteRouter.path(for: .home))
            }
          }
        }

        TerminalWindow {
          Command("brew install pfw")
          Command("pfw login")
          Command("pfw install --tool codex")
          Command("ls -R ~/.codex/skills/the-point-free-way")
          Line { Folder("./ComposableArchitecture/") }
          Line { File("  SKILL.md") }
          Gap()
          Line { Folder("./SQLiteData/") }
          Line { File("  SKILL.md") }
          Gap()
          Line { Folder("./Dependencies/") }
          Line { File("  SKILL.md") }
          Gap()
          Line { Folder("./SwiftNavigation/") }
          Line { File("  SKILL.md") }
        }
        .inlineStyle("margin-top", "2rem", media: .mobile)
      }
    }
    .heroBackground()
  }

  struct AccessUnlocked: HTML {
    var body: some HTML {
      VStack(alignment: .leading, spacing: 0.5) {
        Badge()
        div {
          Header(4) {
            HTMLText("You already have the Point-Free Way.")
          }
          .titleColor()
          .inlineStyle("margin", "0 0 0 0")
        }

        div {
          Paragraph(.small) {
            "Install the tools and start using them in Codex, Claude (and more!) right away."
          }
          .contentColor()
        }

        PFWButton(type: .primary) {
          HTMLText("Install the Point-Free Way")
        }
        .href("https://www.github.com/pointfreeco/pfw-cli")
        .inlineStyle("margin-top", "1rem")
      }
      .inlineStyle("border-left", "3px solid rgb(24, 158, 72)")
      .inlineStyle("padding-left", "1rem")
      .inlineStyle("border-left", "3px solid rgb(162, 255, 200)", media: .dark)
    }
    struct Badge: HTML {
      var body: some HTML {
        span {
          HTMLRaw("&#10003;")
          " Access unlocked"
        }
        .inlineStyle("color", "rgb(24, 158, 72)")
        .inlineStyle("display", "inline-flex")
        .inlineStyle("font-size", "0.8rem")
        .inlineStyle("font-weight", "600")
        .inlineStyle("letter-spacing", "0.04em")
        .inlineStyle("text-transform", "uppercase")
        .badgeLabelStyle(light: "rgb(12, 116, 52)", dark: "rgb(162, 255, 200)")
      }
    }
  }
}

private struct PointFreeWayModule<Content: HTML>: HTML {
  let title: String
  var blurb: String?
  @HTMLBuilder var content: Content
  var body: some HTML {
    PageModule(theme: .content) {
      VStack {
        Header(3) {
          HTMLRaw(title)
        }
        .titleColor()
        HTMLGroup {
          if let blurb {
            Paragraph(.big) {
              HTMLRaw(blurb)
            }
          }
          content
        }
        .contentColor()
      }
      .inlineStyle("width", "100%")
    }
    Divider(size: 100)
      .inlineStyle("display", "none", pseudo: .lastOfType)
  }
}

private struct WhatIsThePointFreeWay: HTML {
  var body: some HTML {
    PointFreeWayModule(
      title: "What is the Point&#8209;Free Way?",
      blurb: """
        The Point-Free Way is a curated collection of AI skill documents designed to guide you 
        toward clear, composable, and testable application architecture.
        """
    ) {
      LazyVGrid(columns: [.desktop: [1, 1]], alignItems: .start, horizontalSpacing: 2) {
        VStack {
          Checklist(items: [
            "Built specifically for Swift and Apple platforms",
            "Deeply integrated with Point-Free libraries",
            "Opinionated, consistent, and maintainable by design",
            "Updated continuously based on releases and weekly community questions",
          ])
          Callout {
            """
            “It's like having Point-Free as your pairing partner!”
            """
          }
        }
        ChecklistModule(
          title: "Designed by industry experts",
          blurb: "Created by the hosts of Point-Free.",
          items: [
            "Maintainers of open source libraries used by tens of thousands of developers",
            "Producer of education videos, millions of minutes watched",
            "Decades of real-world experience and consulting with teams of all sizes",
          ]
        )
      }
    }
  }
}

private struct BuildInThePointFreeStyle: HTML {
  var body: some HTML {
    PointFreeWayModule(title: "Build apps in the Point&#8209;Free style") {
      LazyVGrid(
        columns: [.mobile: [1, 1], .desktop: [2, 1, 1]],
        horizontalSpacing: 2,
        verticalSpacing: 2
      ) {
        ComposableArchitecturePrompt()
          .inlineStyle("grid-column", "1/-1", media: .mobile)

        ChecklistModule(
          title: "Principles",
          items: [
            "Compositional architecture",
            "Value types over reference types",
            "Explicit dependencies",
            "Controlled side effects",
            "Testability by construction",
            "Concise domain modeling",
          ]
        )

        ChecklistModule(
          title: "Libraries",
          items: [
            "Composable Architecture",
            "Dependencies",
            "Swift Navigation",
            "SQLiteData",
            "And more, as they evolve",
          ]
        )
      }
    }
  }
}

private struct HandCrafted: HTML {
  var body: some HTML {
    PointFreeWayModule(
      title: "Hand crafted, not AI generated",
      blurb: """
        Every skill document is handwritten and meticulously tested to ensure it leads to 
        high-quality code.
        """
    ) {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        ChecklistModule(
          title: "What you can expect",
          items: [
            "Practical guidance that results in cleaner designs",
            "Patterns that remain maintainable for years",
            "Guidance aligned with the libraries thousands already",
          ]
        )
        ChecklistModule(
          title: "Always current",
          items: [
            "Updated for new versions of our libraries",
            "Evolved from weekly community questions",
            "Maintained with the same rigor as our codebases",
          ]
        )
      }
    }
  }
}

private struct HowAccessWorks: HTML {
  @Dependency(\.siteRouter) var siteRouter
  @Dependency(\.subscriberState) var subscriberState

  var body: some HTML {
    PointFreeWayModule(title: "How access works") {
      LazyVGrid(columns: [.mobile: [1, 1], .desktop: [1, 1, 1, 1]]) {
        Step(
          count: 1,
          title: "Subscribe to Point&#8209;Free",
          blurb: "Unlock videos and the all Point-Free Way skill documents."
        )
        Step(
          count: 2,
          title: "Sign in to your account",
          blurb: "Your account page includes installation instructions."
        )
        Step(
          count: 3,
          title: "Install the Point&#8209;Free Way",
          blurb: "Add the skills to your workflow (Codex, Claude, etc)."
        )
        Step(
          count: 4,
          title: "Use it wherever you work",
          blurb: "Apply consistent patterns across features and teams."
        )
      }

      CTAGroup {
        if subscriberState.isActiveSubscriber {
          PFWButton(type: .primary) {
            HTMLText("Install the Point-Free Way")
          }
          .href("https://github.com/pointfreeco/pfw-cli")
        } else {
          PFWButton(type: .secondary) {
            HTMLText("View subscription plans")
          }
          .href(siteRouter.path(for: .pricingLanding))
        }
      }
      .inlineStyle("padding-top", "1.5rem")
    }
  }
}

private struct NotReadyToSubscribe: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PointFreeWayModule(
      title: "Not ready to subscribe?",
      blurb: """
        Create a free Point-Free account to access a limited preview of our architectural 
        philosophy and see how we think about building software.
        """
    ) {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        ChecklistModule(
          title: "The Point-Free Primer",
          blurb: """
            A short, read-only preview intended to demonstrate the tone and rigor of the Point-Free 
            Way.
            """,
          items: [
            "High-level architectural principles",
            "Not regularly updated",
            "No library deep dives",
          ]
        ) {
          CTAGroup {
            PFWButton(type: .secondary) {
              HTMLText("Create a free account")
            }
            .href(siteRouter.path(for: .auth(.signUp(redirect: siteRouter.url(for: .theWay)))))
            PFWButton {
              HTMLText("Compare plans")
            }
            .href(siteRouter.path(for: .pricingLanding))
          }
        }
        ChecklistModule(
          title: "Prefer the full experience?",
          blurb: """
            Subscribe to unlock the complete collection of AI skills and access to hundreds of \
            hours of advanced Swift videos.
            """,
          items: [
            "Maintained with the same rigor as our codebases",
            "Evolved from weekly community questions",
            "Updated for new versions of our libraries",
          ]
        ) {
          CTAGroup {
            PFWButton(type: .primary) {
              HTMLText("Subscribe")
            }
            .href(siteRouter.path(for: .pricingLanding))
          }
        }
      }
    }
  }
}

private struct BuildSoftwareThatLasts: HTML {
  @Dependency(\.siteRouter) var siteRouter

  var body: some HTML {
    PageModule(theme: .content) {
      HStack(alignment: .center, spacing: 2) {
        VStack {
          Header(3) {
            "Build software that lasts."
          }
          .titleColor()
          Paragraph(.big) {
            """
            Subscribe to Point-Free and unlock the Point-Free Way: expert guidance, continuously 
            refined.
            """
          }
          .contentColor()
        }
        Spacer()
        VStack {
          PFWButton(type: .primary) {
            "Subscribe now"
          }
          .href(siteRouter.path(for: .pricingLanding))
          .inlineStyle("margin-right", "auto")
        }
      }
    }
    .footerGradientBackground()
  }
}

extension HTML {
  fileprivate func heroBackground() -> some HTML {
    inlineStyle(
      "background",
      """
      radial-gradient(900px 700px at 20% 20%, rgba(76, 204, 255, 0.18), transparent 55%),
      radial-gradient(900px 700px at 80% 70%, rgba(151, 77, 255, 0.16), transparent 55%),
      linear-gradient(180deg, #f6f7fb, #eef1f7)
      """
    )
    .inlineStyle(
      "background",
      """
      radial-gradient(900px 700px at 20% 20%, rgba(76, 204, 255, 0.18), transparent 55%),
      radial-gradient(900px 700px at 80% 70%, rgba(151, 77, 255, 0.16), transparent 55%),
      linear-gradient(180deg, #07080b, #0b0d10)
      """,
      media: .dark
    )
  }
  fileprivate func footerGradientBackground() -> some HTML {
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
  fileprivate func border() -> some HTML {
    inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
      .inlineStyle("border-color", "rgba(255, 255, 255, 0.12)", media: .dark)
  }
  fileprivate func panel(mini: Bool = false) -> some HTML {
    border()
      .inlineStyle("border-radius", "1rem")
      .inlineStyle("background", "#fcfcfc")
      .inlineStyle("background", "#0f1220", media: .dark)
      .inlineStyle("box-shadow", "none")
      .inlineStyle("padding", mini ? "1rem" : "1.5rem")
  }
  fileprivate func titleColor() -> some HTML {
    color(.black.dark(.white))
  }
  fileprivate func contentColor() -> some HTML {
    color(.gray300.dark(.gray800))
  }
  fileprivate func checklistListStyle() -> some HTML {
    inlineStyle("margin", "1rem 0 0")
      .inlineStyle("padding", "0")
      .inlineStyle("list-style", "none")
      .inlineStyle("display", "grid")
      .inlineStyle("gap", "0.75rem")
  }
  fileprivate func badgeLabelStyle(light: String, dark: String) -> some HTML {
    inlineStyle("color", light)
      .inlineStyle("display", "inline-flex")
      .inlineStyle("font-size", "0.8rem")
      .inlineStyle("font-weight", "600")
      .inlineStyle("letter-spacing", "0.04em")
      .inlineStyle("text-transform", "uppercase")
      .inlineStyle("color", dark, media: .dark)
  }
}


fileprivate struct ComposableArchitecturePrompt: HTML {
  var body: some HTML {
    TerminalWindow(title: "Pomodoro – codex", maxHeight: 22) {
      CodexCommand(
        command: """
          $ComposableArchitecture Produce a snippet of code that implements a pomodoro \
          timer feature.
          """
      )
      Gap()
      Line(prefix: "•") {
        "Using The Composable Architecture skill (requested)."
      }
      Gap()
      Line {
        Code(
          """
            import ComposableArchitecture
            import SwiftUI

            @Feature struct Pomodoro {
              struct State {
                var isRunning = false
                var remainingSeconds = 25 * 60
                var totalSeconds = 25 * 60
              }
              enum Action {
                case startButtonTapped
                case pauseButtonTapped
                case resetButtonTapped
                case timerTick
              }

              var body: some Feature<State, Action> {
                Update { state, action in
                  switch action {
                  case .startButtonTapped:
                    state.isRunning = true
                    return .none

                  case .pauseButtonTapped:
                    state.isRunning = false
                    return .none

                  case .resetButtonTapped:
                    state.isRunning = false
                    state.remainingSeconds = state.totalSeconds
                    return .none

                  case .timerTick:
                    guard state.remainingSeconds > 0 else {
                      state.isRunning = false
                      return .none
                    }
                    state.remainingSeconds -= 1
                    return .none
                  }
                }
                .onMount(id: store.isRunning) { store in
                  guard try store.isRunning else { return }
                  while true {
                    try await Task.sleep(for: .seconds(1))
                    try store.send(.timerTick)
                  }
                }
              }
            }

            struct PomodoroView: View {
              let store: StoreOf<Pomodoro>

              var body: some View {
                VStack(spacing: 16) {
                  Text(timeString(from: store.remainingSeconds))
                  HStack(spacing: 12) {
                    Button("Start") { 
                      store.send(.startButtonTapped) 
                    }
                    .disabled(store.isRunning)

                    Button("Pause") { 
                      store.send(.pauseButtonTapped) 
                    }
                    .disabled(!store.isRunning)

                    Button("Reset") { 
                      store.send(.resetButtonTapped) 
                    }
                  }
                }
                .padding()
              }

              private func timeString(from seconds: Int) -> String {
                let minutes = seconds / 60
                let seconds = seconds % 60
                return String(format: "%02d:%02d", minutes, seconds)
              }
            }

            #Preview {
              PomodoroView(
                store: Store(initialState: Pomodoro.State()) {
                  Pomodoro()
                }
              )
            }
          """
        )
      }
    }
  }
}
