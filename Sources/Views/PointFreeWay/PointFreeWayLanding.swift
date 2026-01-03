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
    PageModule(theme: .content) {
      HStack {
        VStack {
          Header(3) {
            HTMLRaw("The Point-Free Way")
          }
          Paragraph {
            "Expert-crafted AI skill documents for building long-lasting Swift applications."
          }
        }
        .color(.black.dark(.white))

        TerminalWindow()
      }

      TerminalWindow()
    }
  }
}

struct TerminalWindow: HTML {
  var body: some HTML {
    tag("terminal-window") {
      TitleBar()
      Screen()
    }
    .inlineStyle("width", "min(980px, 92vw)")
    .inlineStyle("border-radius", "18px")
    .inlineStyle("background", "rgba(250, 251, 253, 0.92)")
    .inlineStyle("background", "rgba(14, 16, 20, 0.92)", media: .dark)
    .inlineStyle("border", "1px solid")
    .inlineStyle("border-color", "rgba(10, 14, 20, 0.10)")
    .inlineStyle("border-color", "rgba(255, 255, 255, 0.10)", media: .dark)
    .inlineStyle("box-shadow", "0 24px 70px rgba(0, 0, 0, 0.20)")
    .inlineStyle("box-shadow", "0 24px 70px rgba(0, 0, 0, 0.45)", media: .dark)
    .inlineStyle("overflow", "hidden")
    .inlineStyle("backdrop-filter", "blur(10px)")
    .inlineStyle("-webkit-backdrop-filter", "blur(10px)")
  }

  struct Screen: HTML {
    var body: some HTML {
      div {
        p {
          span { "~/.codex.skills/the-point-free-way" }
          span { "$" }
          span { "ls -R" }
        }
        div {}
        Line(skill: "ComposableArchitecture")
        Line(skill: "SQLiteData")
        Line(skill: "Dependencies")
        Line(skill: "SwiftNavigation")
      }
      .inlineStyle("position", "relative")
      .inlineStyle("padding", "18px 18px 20px")
      .inlineStyle(
        "font-family",
        "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace"
      )
      .inlineStyle("font-size", "16px")
      .inlineStyle("line-height", "1.55")
      //.inlineStyle("color", "var(--term-text)")
      .color(.init(rawValue: "rgba(10, 14, 20, 0.86)", darkValue: "rgba(255, 255, 255, 0.86)"))

      .inlineStyle("content", "", pseudo: .before)
      .inlineStyle("position", "absolute", pseudo: .before)
      .inlineStyle("inset", "0", pseudo: .before)
      .inlineStyle("pointer-events", "none", pseudo: .before)
      .inlineStyle("opacity", "0.10", pseudo: .before)
      .inlineStyle(
        "background",
        "repeating-linear-gradient(to bottom, rgba(10, 14, 20, 0.06), rgba(10, 14, 20, 0.06) 1px, transparent 1px, transparent 7px)",
        pseudo: .before
      )
    }
  }

  struct Line: HTML {
    let skill: String
    var body: some HTML {
      p {
        span {
          HTMLText("./" + skill + "/")
        }
        .inlineStyle(
          "color",
          "color-mix(in oklab, \(PointFreeColor.green.rawValue) 82%, rgba(10, 14, 20, 0.86) 10%);"
        )
        .inlineStyle(
          "color",
          "color-mix(in oklab, \(PointFreeColor.green.rawValue) 82%, rgba(255, 255, 255, 0.86) 10%);",
          media: .dark
        )
      }
      .inlineStyle("position", "relative")
      .inlineStyle("margin", "0")
      .inlineStyle("white-space", "pre")
      p {
        span { "SKILL.md" }
      }
      .inlineStyle(
        "color",
        "color-mix(in oklab, \(PointFreeColor.blue.rawValue) 82%, rgba(10, 14, 20, 0.86) 10%);"
      )
      .inlineStyle(
        "color",
        "color-mix(in oklab, \(PointFreeColor.blue.rawValue) 82%, rgba(255, 255, 255, 0.86) 10%);",
        media: .dark
      )
    }
  }

  struct TitleBar: HTML {
    var body: some HTML {
      tag("terminal-title-bar") {
        div {
          Dots()
        }
        .inlineStyle("display", "inline-flex")
        .inlineStyle("gap", "8px")
        .inlineStyle("padding-left", "4px")

        div {
          "Terminal"
        }
        .inlineStyle("text-align", "center")
        .inlineStyle("font-size", "14px")
        .inlineStyle("letter-spacing", "0.02em")
        .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 72%, transparent)")
        .inlineStyle(
          "color",
          "color-mix(in oklab, rgba(255, 255, 255, 0.86) 72%, transparent)",
          media: .dark
        )
        .inlineStyle("user-select", "none")

        div {}
          .inlineStyle("width", "38px")
      }
      .inlineStyle("display", "grid")
      .inlineStyle("grid-template-columns", "auto 1fr auto")
      .inlineStyle("align-items", "center")
      .inlineStyle("gap", "1rem")
      .padding(1)
      .color(.init(rawValue: "rgba(10, 14, 20, 0.06)", darkValue: "rgba(255,255,255,0.06)"))
      .inlineStyle("border-bottom", "1px solid")
      .inlineStyle("border-bottom-color", "rgba(10, 14, 20, 0.10)")
      .inlineStyle("border-bottom-color", "rgba(255, 255, 255, 0.10)", media: .dark)
    }
  }

  struct Dots: HTML {
    var body: some HTML {
      Dot(color: .red)
      Dot(color: .yellow)
      Dot(color: .green)
    }
  }
  struct Dot: HTML {
    enum Color {
      case red, yellow, green
      var hexString: String {
        switch self {
        case .red: "#ff5f57"
        case .yellow: "#febc2e"
        case .green: "#28c840"
        }
      }
    }
    let color: Color
    var body: some HTML {
      span {}
        .inlineStyle("width", "12px")
        .inlineStyle("height", "12px")
        .inlineStyle("border-radius", "999px")
        .inlineStyle("box-shadow", "inset 0 0 0 1px rgba(0, 0, 0, 0.18)")
        .inlineStyle("background", color.hexString)
    }
  }
}
