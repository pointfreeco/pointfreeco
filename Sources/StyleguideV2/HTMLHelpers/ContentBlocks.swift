public struct ChecklistModule<Footer: HTML>: HTML {
  let title: String
  let blurb: String?
  let items: [String]
  let footer: Footer

  public init(
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

  public var body: some HTML {
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

public struct Checklist: HTML {
  let items: [String]

  public init(items: [String]) {
    self.items = items
  }

  public var body: some HTML {
    ul {
      for item in items {
        ChecklistItem(text: item)
      }
    }
    .checklistListStyle()
  }

  private struct ChecklistItem: HTML {
    let text: String
    var body: some HTML {
      li {
        Check()
        HTMLRaw(text)
      }
      .inlineStyle("display", "flex")
      .inlineStyle("gap", "10px")
      .inlineStyle("align-items", "flex-start")
    }
  }

  private struct Check: HTML {
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

public struct CTAGroup<Content: HTML>: HTML {
  let spacing: Double?
  let content: Content

  public init(spacing: Double? = nil, @HTMLBuilder content: () -> Content) {
    self.spacing = spacing
    self.content = content()
  }

  public var body: some HTML {
    HStack(alignment: .firstTextBaseline, spacing: spacing) {
      content
      Spacer()
    }
  }
}

public struct Callout<Content: HTML>: HTML {
  let content: Content

  public init(@HTMLBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some HTML {
    blockquote {
      content
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
    .inlineStyle("font-size", "1.5rem")
    .inlineStyle("font-style", "italic")
  }
}

public struct Step: HTML {
  let count: Int
  let title: String
  let blurb: String

  public init(count: Int, title: String, blurb: String) {
    self.count = count
    self.title = title
    self.blurb = blurb
  }

  public var body: some HTML {
    HStack(alignment: .firstTextBaseline, spacing: 0.5) {
      block("step-count") {
        HTMLRaw(count.description)
      }
      .inlineStyle("aspect-ratio", "1 / 1")
      .inlineStyle("width", "30px")
      .inlineStyle("height", "30px")
      .inlineStyle("min-width", "30px")
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
    .panel(mini: true)
    .inlineStyle("padding", "1rem")
  }
}

private extension HTML {
  func border() -> some HTML {
    inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
      .inlineStyle("border-color", "rgba(255, 255, 255, 0.12)", media: .dark)
  }

  func panel(mini: Bool = false) -> some HTML {
    border()
      .inlineStyle("border-radius", "1rem")
      .inlineStyle("background", "#fcfcfc")
      .inlineStyle("background", "#0f1220", media: .dark)
      .inlineStyle("box-shadow", "none")
      .inlineStyle("padding", mini ? "1rem" : "1.5rem")
  }

  func titleColor() -> some HTML {
    color(.black.dark(.white))
  }

  func contentColor() -> some HTML {
    color(.gray300.dark(.gray800))
  }

  func checklistListStyle() -> some HTML {
    inlineStyle("margin", "1rem 0 0")
      .inlineStyle("padding", "0")
      .inlineStyle("list-style", "none")
      .inlineStyle("display", "grid")
      .inlineStyle("gap", "0.75rem")
  }
}
