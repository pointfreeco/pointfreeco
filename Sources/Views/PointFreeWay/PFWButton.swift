import StyleguideV2

struct PFWButton<Label: HTML>: HTML {
  var type: ButtonType?
  @HTMLBuilder let label: Label

  enum ButtonType {
    case primary
    case secondary
  }

  var body: some HTML {
    switch type {
    case .primary:
      base
        .inlineStyle(
          "border-color",
          "color-mix(in oklab, #79f2b0 40%, rgba(15, 18, 32, 0.12))"
        )
        .inlineStyle(
          "border-color",
          "color-mix(in oklab, #79f2b0 40%, rgba(255, 255, 255, 0.12))",
          media: .dark
        )
        .inlineStyle("background", "color-mix(in oklab, #79f2b0 22%, #ffffff)")
        .inlineStyle(
          "background",
          "color-mix(in oklab, #79f2b0 22%, #0f1220)",
          media: .dark
        )
    case .secondary:
      base
        .inlineStyle(
          "border-color",
          "color-mix(in oklab, #4cccff 40%, rgba(15, 18, 32, 0.12))"
        )
        .inlineStyle(
          "border-color",
          "color-mix(in oklab, #4cccff 40%, rgba(255, 255, 255, 0.12))",
          media: .dark
        )
        .inlineStyle("background", "color-mix(in oklab, #4cccff 18%, #ffffff)")
        .inlineStyle(
          "background",
          "color-mix(in oklab, #4cccff 18%, #0f1220)",
          media: .dark
        )
    case .none:
      base
        .inlineStyle("background", "#ffffff")
        .inlineStyle("background", "#0f1220", media: .dark)
    }
  }

  var base: some HTML {
    a {
      label
    }
    .inlineStyle("display", "inline-flex")
    .inlineStyle("align-items", "center")
    .inlineStyle("justify-content", "center")
    .inlineStyle("gap", "10px")
    .inlineStyle("padding", "0.75rem 1rem")
    .font()
    .border()
    .inlineStyle("cursor", "pointer")
    .inlineStyle(
      "transition",
      "transform 120ms ease, box-shadow 120ms ease, border-color 120ms ease, background 120ms ease"
    )
    .inlineStyle("user-select", "none")
    .inlineStyle("text-decoration", "none")
    .inlineStyle("text-decoration", "none", pseudo: .hover)
    .inlineStyle("transform", "translateY(-1px)", pseudo: .hover)

    .inlineStyle("transform", "translateY(0)", pseudo: .active)
    .boxShadow()
    .color(PointFreeColor(rawValue: "#0f1220", darkValue: "rgba(255, 255, 255, 0.92)"))
    .color(PointFreeColor(rawValue: "#0f1220", darkValue: "rgba(255, 255, 255, 0.92)"), .link)
    .color(PointFreeColor(rawValue: "#0f1220", darkValue: "rgba(255, 255, 255, 0.92)"), .visited)

  }

}

extension HTML {
  fileprivate func font() -> some HTML {
    inlineStyle("font-weight", "650")
      .inlineStyle("font-size", "0.98rem")
      .inlineStyle("line-height", "1")
  }
  fileprivate func border() -> some HTML {
    inlineStyle("border-radius", "999px")
      .inlineStyle("border", "1px solid rgba(15, 18, 32, 0.12)")
      .inlineStyle("border", "1px solid rgba(255, 255, 255, 0.12)", media: .dark)
  }
  fileprivate func boxShadow() -> some HTML {
    inlineStyle("box-shadow", "none")
      .inlineStyle("box-shadow", "0 12px 30px rgba(15, 18, 32, 0.08)", pseudo: .hover)
      .inlineStyle("box-shadow", "0 16px 40px rgba(0, 0, 0, 0.35)", media: .dark, pseudo: .hover)
      .inlineStyle("box-shadow", "none", pseudo: .active)
  }
}
