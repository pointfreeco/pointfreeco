import StyleguideV2

struct TerminalWindow<Content: HTML>: HTML {
  var title: String?
  var maxHeight: Int?
  @HTMLBuilder var content: Content
  var body: some HTML {
    block("terminal-window") {
      TitleBar(title: title)
      Screen(content: content, maxHeight: maxHeight)
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
    let content: Content
    let maxHeight: Int?
    var body: some HTML {
      block("terminal-screen") {
        block("terminal-viewport") {
          content
          if maxHeight != nil {
            Gap()
          }
        }
        .inlineStyle("position", "relative")
        .inlineStyle("padding", "1rem")
        .inlineStyle("width", "100%")
        .inlineStyle("overflow-y", "scroll")
        .inlineStyle("scrollbar-gutter", "stable both-edges")
        .inlineStyle("max-height", maxHeight.map { "\($0)rem" })
        .inlineStyle("color-scheme", "light dark")

        if maxHeight != nil {
          block("terminal-fade") {

          }
          .inlineStyle("position", "absolute")
          .inlineStyle("left", "0")
          .inlineStyle("right", "0")
          .inlineStyle("bottom", "0")
          .inlineStyle("height", "6rem")
          .inlineStyle("pointer-events", "none")
          .inlineStyle(
            "background",
            "linear-gradient(to bottom, transparent, rgba(250, 251, 253, 0.98))"
          )
          .inlineStyle(
            "background",
            "linear-gradient(to bottom, transparent, rgba(14, 16, 20, 0.98))",
            media: .dark
          )
        }
      }
      .inlineStyle(
        "font-family",
        "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, \"Liberation Mono\", \"Courier New\", monospace"
      )
      .inlineStyle("font-size", "16px")
      .inlineStyle("line-height", "1.55")
      .color(.init(rawValue: "rgba(10, 14, 20, 0.86)", darkValue: "rgba(255, 255, 255, 0.86)"))
    }
  }

  struct TitleBar: HTML {
    let title: String?
    var body: some HTML {
      block("terminal-title-bar") {
        div {
          Dots()
        }
        .inlineStyle("display", "inline-flex")
        .inlineStyle("gap", "0.5rem")
        .inlineStyle("padding-left", "0.25rem")

        div {
          HTMLRaw(title ?? "Terminal")
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

struct Command: HTML {
  let command: String
  init(_ command: String) {
    self.command = command
  }
  var body: some HTML {
    Line(prefix: "$") {
      span { HTMLRaw(command) }
        .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 96%, transparent)")
        .inlineStyle(
          "color",
          "color-mix(in oklab, rgba(255, 255, 255, 0.86) 96%, transparent)",
          media: .dark
        )
    }
  }
}

struct CodexCommand: HTML {
  let command: String
  var body: some HTML {
    Line(prefix: "›", background: .gray850.dark(.gray300)) {
      span { HTMLRaw(command) }
        .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 96%, transparent)")
        .inlineStyle(
          "color",
          "color-mix(in oklab, rgba(255, 255, 255, 0.86) 96%, transparent)",
          media: .dark
        )
    }
  }
}

struct Line<Content: HTML>: HTML {
  var prefix: String?
  var background: PointFreeColor?
  @HTMLBuilder var content: Content
  var body: some HTML {
    HStack(spacing: 1) {
      if let prefix {
        span { HTMLRaw(prefix) }
          .inlineStyle("width", "0px")
          .inlineStyle("color", "color-mix(in oklab, rgba(10, 14, 20, 0.86) 60%, transparent)")
          .inlineStyle(
            "color",
            "color-mix(in oklab, rgba(255, 255, 255, 0.86) 68%, transparent)",
            media: .dark
          )
      }
      content
    }
    .inlineStyle("position", "relative")
    .inlineStyle("margin", "0 -1rem")
    .inlineStyle("white-space", "pre-wrap")
    .inlineStyle("overflow-wrap", "anywhere")
    .inlineStyle("word-break", "break-word")
    .inlineStyle("padding", "2px 1rem")
    .background(background)
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
      HTMLText(folder)
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

struct Code: HTML {
  let code: String
  init(_ code: String) {
    self.code = code
  }
  var body: some HTML {
    span {
      HTMLText(code)
    }
    .inlineStyle(
      "color",
      "color-mix(in oklab, \(PointFreeColor.green.rawValue) 82%, #000 20%);"
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
