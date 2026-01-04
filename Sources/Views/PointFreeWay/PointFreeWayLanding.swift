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
  public init() {}

  public var body: some HTML {
    PointFreeWayHeader()
    WhatIsThePointFreeWay()
    BuildInThePointFreeStyle()
    HandCrafted()
    HowAccessWorks()
    NotReadyToSubscribe()
    BuildSoftwareThatLasts()
  }
}

private struct PointFreeWayHeader: HTML {
  var body: some HTML {
    PageModule(theme: .content) {
      LazyVGrid(columns: [.desktop: [1, 1]]) {
        VStack {
          Header(2) {
            HTMLRaw("The Point&#8209;Free Way")
          }
          .titleColor()
          Paragraph(.big) {
            "Expert-crafted AI skill documents for building long-lasting Swift applications."
          }
          .contentColor()
          Paragraph(.small) {
            HTMLRaw(
              """
              Design, test, and evolve applications using the same principles, libraries, 
              and techniques we use every day at Point&#8209;Free.
              """
            )
          }
          .contentColor()
          HStack {
            PFWButton(type: .primary) {
              HTMLText("Subscribe to unlock")
            }
            .href("/pricing")
            PFWButton {
              HTMLText("Explore Point-Free")
            }
            .href("/")
            Spacer()
          }
        }

        TerminalWindow()
          .inlineStyle("margin-top", "2rem", media: .mobile)
      }
    }
    .inlineStyle(
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
    }
    DividerLine()
  }
}

struct DividerLine: HTML {
  var body: some HTML {
    hr()
      .inlineStyle("border", "none")
      .inlineStyle("border-top", "1px solid \(PointFreeColor.gray800.rawValue)")
      .inlineStyle("border-top", "1px solid \(PointFreeColor.gray300.rawValue)", media: .dark)
      .inlineStyle("display", "none", media: .dark, pseudo: .lastOfType)
  }
}

private struct ChecklistModule<Footer: HTML>: HTML {
  let title: String
  var blurb: String?
  var items: [String]
  var footer: Footer
  init(
    title: String,
    blurb: String? = nil,
    items: [String],
    @HTMLBuilder footer: () -> Footer = { HTMLEmpty() }
  ) {
    self.title = title
    self.blurb = blurb
    self.items = items
    self.footer = footer()
  }
  var body: some HTML {
    VStack(alignment: .leading, spacing: 0) {
      Header(4) {
        HTMLRaw(title)
      }
      .titleColor()
      HTMLGroup {
        if let blurb {
          Paragraph {
            HTMLRaw(blurb)
          }
        }
        Checklist(items: items)
      }
      .contentColor()
      footer
        .inlineStyle("padding-top", "1.5rem")
    }
    .panel()
  }
}
private struct Checklist: HTML {
  let items: [String]
  var body: some HTML {
    ul {
      for item in items {
        li {
          Check()
          HTMLRaw(item)
        }
        .inlineStyle("display", "flex")
        .inlineStyle("gap", "10px")
        .inlineStyle("align-items", "flex-start")
      }
    }
    .inlineStyle("margin", "1rem 0 0")
    .inlineStyle("padding", "0")
    .inlineStyle("list-style", "none")
    .inlineStyle("display", "grid")
    .inlineStyle("gap", "0.75rem")
  }
  struct Check: HTML {
    var body: some HTML {
      svg {
        HTMLRaw(
          """
          <path stroke="#79f2b0" d="M20 6L9 17l-5-5" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"></path>
          """
        )
      }
      .attribute("viewBox", "0 0 24 24")
      .attribute("fill", "none")
      .attribute("aria-hidden", "true")
      .inlineStyle("width", "18px")
      .inlineStyle("height", "18px")
      .inlineStyle("flex", "0 0 auto")
      .inlineStyle("margin-top", "2px")
    }
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
      LazyVGrid(columns: [.desktop: [1, 1]], horizontalSpacing: 2) {
        VStack {
          Checklist(items: [
            "Built specifically for Swift and Apple platforms",
            "Deeply integrated with Point-Free libraries",
            "Opinionated, consistent, and maintainable by design",
            "Updated continuously based on releases and weekly community questions",
          ])
          PullQuote()
        }
        ChecklistModule(
          title: "Designed by industry experts",
          blurb: "Created by the hosts of Point-Free.",
          items: [
            "Maintainers of open source libraries used by thousands of developers",
            "Producer of education videos, watched by tens of thousands of developers",
            "Decades of real-world experience and consulting with teams of all sizes",
          ]
        )
      }
    }
  }
}

private struct PullQuote: HTML {
  var body: some HTML {
    blockquote {
      """
      “It's like having Point-Free as your pairing partner!”
      """
    }
    .inlineStyle("margin", "2rem auto 0 0")
    .inlineStyle("padding", "1.5rem")
    .inlineStyle(
      "border-left",
      "3px solid color-mix(in oklab, #974dff 65%, rgba(15, 18, 32, 0.12))"
    )
    .inlineStyle(
      "border-left",
      "3px solid color-mix(in oklab, #974dff 65%, rgba(255, 255, 255, 0.12))",
      media: .dark
    )
    .inlineStyle("border-radius", "0.75rem")
    .inlineStyle("background", "color-mix(in oklab, #974dff 10%, #ffffff)")
    .inlineStyle("background", "color-mix(in oklab, #974dff 10%, #0f1220)", media: .dark)
    .inlineStyle("color", "#0f1220cc")
    .inlineStyle("color", "rgba(255, 255, 255, 0.92)", media: .dark)
    .inlineStyle("font-size", "1.25rem")
    .inlineStyle("font-style", "italic")
  }
}

private struct BuildInThePointFreeStyle: HTML {
  var body: some HTML {
    PointFreeWayModule(title: "Build apps in the Point&#8209;Free style") {
      HStack {
        ChecklistModule(
          title: "Principles",
          items: [
            "Compositional architecture",
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

      HStack {
        PFWButton(type: .secondary) {
          HTMLText("View subscription plans")
        }
        .href("/pricing")
        Spacer()
      }
      .inlineStyle("padding-top", "1.5rem")
    }
  }

  struct Step: HTML {
    let count: Int
    let title: String
    let blurb: String
    var body: some HTML {
      HStack(alignment: .firstTextBaseline, spacing: 0.5) {
        block("step-count") {
          HTMLRaw(count.description)
        }
        .inlineStyle("width", "30px")
        .inlineStyle("height", "30px")
        .inlineStyle("border-radius", "999px")
        .inlineStyle("display", "grid")
        .inlineStyle("place-items", "center")
        .inlineStyle("font-weight", "750")
        .inlineStyle("font-size", "0.95rem")
        .titleColor()
        .border()
        .inlineStyle("background", "color-mix(in oklab, #4cccff 12%, #ffffff)")
        .inlineStyle("background", "color-mix(in oklab, #4cccff 12%, #0f1220)", media: .dark)

        VStack(spacing: 0) {
          Header(5) { HTMLRaw(title) }
            .titleColor()
          Paragraph { HTMLRaw(blurb) }
            .contentColor()
        }
      }
      .panel()
      .inlineStyle("padding", "1.25rem")
    }
  }
}

private struct NotReadyToSubscribe: HTML {
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
          HStack {
            PFWButton(type: .secondary) {
              HTMLText("Create a free account")
            }
            .href("/signup")
            PFWButton {
              HTMLText("Compare plans")
            }
            .href("/pricing")
          }
        }
        ChecklistModule(
          title: "Prefer the full experience?",
          blurb: """
            Subscribe to unlock the complete collection, including library-specific guidance and 
            frequently updated best practices.
            """,
          items: [
            "Maintained with the same rigor as our codebases",
            "Evolved from weekly community questions",
            "Updated for new versions of our libraries",
          ]
        ) {
          HStack {
            PFWButton(type: .primary) {
              HTMLText("Subscribe")
            }
            .href("/pricing")
          }
        }
      }
    }
  }
}

private struct BuildSoftwareThatLasts: HTML {
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
          Button(color: .purple) {
            "Subscribe now"
          }
          .inlineStyle("margin-right", "auto")
        }
      }
    }
    .inlineStyle(
      "background",
      """
      linear-gradient(
        180deg, 
        color-mix(in oklab, #ffffff 100%, transparent) 0%, 
        color-mix(in oklab, #974dff 30%, #ffffff) 100%
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

extension HTML {
  fileprivate func border() -> some HTML {
    inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
      .inlineStyle("border-color", "rgba(255, 255, 255, 0.12)", media: .dark)
  }
  fileprivate func panel() -> some HTML {
    border()
      .inlineStyle("border-radius", "1rem")
      .inlineStyle("background", "#fcfcfc")
      .inlineStyle("background", "#0f1220", media: .dark)
      .inlineStyle("box-shadow", "none")
      .inlineStyle("padding", "1.5rem")
  }
  fileprivate func titleColor() -> some HTML {
    color(.black.dark(.white))
  }
  fileprivate func contentColor() -> some HTML {
    color(.gray300.dark(.gray800))
  }
}
