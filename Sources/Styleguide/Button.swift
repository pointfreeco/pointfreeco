import Css
import Prelude

public let button: Stylesheet =
  display(.inlineBlock)
    <> background(Color.gray730)
    <> color(.white)
    <> lineHeight(1)
    <> fontWeight(.bold)
    <> padding(topBottom: .rem(0.5), leftRight: .rem(1))
    <> borderRadius(all: .px(6))
    <> borderWidth(all: 0)

public let buttonClass = ".btn" % (
  button
)
