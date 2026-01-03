import StyleguideV2

struct TerminalWindow: HTML {
  var body: some HTML {
    block("terminal-window") {
      TitleBar()
      Screen()
    }
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
      block("terminal-screen") {
        Line {
          span { "~/.codex.skills/the-point-free-way" }
            .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 60%, transparent)")
            .inlineStyle(
              "color",
              "color-mix(in oklab, rgba(255, 255, 255, 0.86) 88%, transparent)",
              media: .dark
            )
          span { " $ " }
            .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 60%, transparent)")
            .inlineStyle(
              "color",
              "color-mix(in oklab, rgba(255, 255, 255, 0.86) 68%, transparent)",
              media: .dark
            )
          span { "ls -R" }
            .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 96%, transparent)")
            .inlineStyle(
              "color",
              "color-mix(in oklab, rgba(255, 255, 255, 0.86) 96%, transparent)",
              media: .dark
            )
        }
        Gap()
        Line { Folder("ComposableArchitecture") }
        Line { File("  SKILL.md") }
        Gap()
        Line { Folder("SQLiteData") }
        Line { File("  SKILL.md") }
        Gap()
        Line { Folder("Dependencies") }
        Line { File("  SKILL.md") }
        Gap()
        Line { Folder("SwiftNavigation") }
        Line { File("  SKILL.md") }
      }
      .inlineStyle("position", "relative")
      .inlineStyle("padding", "1.125rem 3rem 1.25rem 1.125rem")
      .inlineStyle(
        "font-family",
        "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace"
      )
      .inlineStyle("font-size", "16px")
      .inlineStyle("line-height", "1.55")
      .color(.init(rawValue: "rgba(10, 14, 20, 0.86)", darkValue: "rgba(255, 255, 255, 0.86)"))
    }
  }

  struct Line<Content: HTML>: HTML {
    @HTMLBuilder var content: Content
    var body: some HTML {
      p {
        content
      }
      .inlineStyle("position", "relative")
      .inlineStyle("margin", "0")
      .inlineStyle("white-space", "pre")
    }
  }
  struct File: HTML {
    let file: String
    init(_ file: String) {
      self.file = file
    }
    var body: some HTML {
      span {
        HTMLText(file)
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
  struct Folder: HTML {
    let folder: String
    init(_ folder: String) {
      self.folder = folder
    }
    var body: some HTML {
      span {
        HTMLText("./" + folder + "/")
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
  }
  struct Gap: HTML {
    var body: some HTML {
      block("terminal-gap") {}.inlineStyle("height", "0.625rem")
    }
  }

  struct TitleBar: HTML {
    var body: some HTML {
      block("terminal-title-bar") {
        div {
          Dots()
        }
        .inlineStyle("display", "inline-flex")
        .inlineStyle("gap", "0.5rem")
        .inlineStyle("padding-left", "0.25rem")

        div {
          "Terminal"
        }
        .inlineStyle("text-align", "center")
        .inlineStyle("font-size", "0.875rem")
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
