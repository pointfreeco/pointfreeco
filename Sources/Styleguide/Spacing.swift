import Css
import Prelude

public let spacing: Stylesheet =
  padding0 % padding(all: 0)
    <> padding0_5 % padding(all: .rem(0.5))
    <> padding1 % padding(all: .rem(1))
    <> padding2 % padding(all: .rem(2))
    <> padding3 % padding(all: .rem(3))
    <> padding4 % padding(all: .rem(4))
    <> padding5 % padding(all: .rem(5))

    <> paddingTop0 % padding(top: 0)
    <> paddingTop0_5 % padding(top: .rem(0.5))
    <> paddingTop1 % padding(top: .rem(1))
    <> paddingTop2 % padding(top: .rem(2))
    <> paddingTop3 % padding(top: .rem(3))
    <> paddingTop4 % padding(top: .rem(4))
    <> paddingTop5 % padding(top: .rem(5))

private let padding0 = CssSelector.class("p0")
private let padding0_5 = CssSelector.class("p0_5")
private let padding1 = CssSelector.class("p1")
private let padding2 = CssSelector.class("p2")
private let padding3 = CssSelector.class("p3")
private let padding4 = CssSelector.class("p4")
private let padding5 = CssSelector.class("p5")

private let paddingTop0 = CssSelector.class("pt0")
private let paddingTop0_5 = CssSelector.class("pt0_5")
private let paddingTop1 = CssSelector.class("pt1")
private let paddingTop2 = CssSelector.class("pt2")
private let paddingTop3 = CssSelector.class("pt3")
private let paddingTop4 = CssSelector.class("pt4")
private let paddingTop5 = CssSelector.class("pt5")

private let paddingLeft0 = CssSelector.class("pl0")
private let paddingLeft0_5 = CssSelector.class("pl0_5")
private let paddingLeft1 = CssSelector.class("pl1")
private let paddingLeft2 = CssSelector.class("pl2")
private let paddingLeft3 = CssSelector.class("pl3")
private let paddingLeft4 = CssSelector.class("pl4")
private let paddingLeft5 = CssSelector.class("pl5")
