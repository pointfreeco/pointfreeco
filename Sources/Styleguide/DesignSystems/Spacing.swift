import Css
import Prelude

public enum Side: String {
  case all = ""
  case bottom = "b"
  case left = "l"
  case leftRight = "x"
  case right = "r"
  case top = "t"
  case topBottom = "y"

  fileprivate static let allSides: [Side] = [.all, .bottom, .left, .leftRight, .right, .top, .topBottom]
}

extension Class {
  public static func padding(_ data: [_Breakpoint: [Side: Int]]) -> CssSelector {
    let classes = data.flatMap { breakpoint, sides in
      sides.map { side, n in
        CssSelector.class("\(breakpoint.rawValue)-p\(side.rawValue)\(n)")
      }
    }
    return classes.dropFirst().reduce(classes.first ?? .class("not-found"), |)
  }

  public static func margin(_ data: [_Breakpoint: [Side: Int]]) -> CssSelector {
    let classes = data.flatMap { breakpoint, sides in
      sides.map { side, n in
        CssSelector.class("\(breakpoint.rawValue)-m\(side.rawValue)\(n)")
      }
    }
    return classes.dropFirst().reduce(classes.first ?? .class("not-found"), |)
  }
}

public let spacingStyles =
  responsivePaddingStyles
    <> responsiveMarginStyles

private let responsivePaddingStyles = Side.allSides
  .flatMap { side in
    _Breakpoint.all.flatMap { breakpoint in
      spacings.enumerated().map { n, size in
        breakpoint.querySelfAndBigger(only: screen) {
          Class.padding([breakpoint: [side: n]]) % paddingStyle(side: side, size: size)
        }
      }
    }
  }.concat()

private let responsiveMarginStyles = Side.allSides
  .flatMap { side in
    _Breakpoint.all.flatMap { breakpoint in
      spacings.enumerated().map { n, size in
        breakpoint.querySelfAndBigger(only: screen) {
          Class.margin([breakpoint: [side: n]]) % marginStyle(side: side, size: size)
        }
      }
    }
  }.concat()

private func paddingStyle(side: Side, size: Size) -> Stylesheet {
  switch side {
  case .all:
    return padding(all: size)
  case .bottom:
    return padding(bottom: size)
  case .left:
    return padding(left: size)
  case .leftRight:
    return padding(leftRight: size)
  case .right:
    return padding(right: size)
  case .top:
    return padding(top: size)
  case .topBottom:
    return padding(topBottom: size)
  }
}

private func marginStyle(side: Side, size: Size) -> Stylesheet {
  switch side {
  case .all:
    return margin(all: size)
  case .bottom:
    return margin(bottom: size)
  case .left:
    return margin(left: size)
  case .leftRight:
    return margin(leftRight: size)
  case .right:
    return margin(right: size)
  case .top:
    return margin(top: size)
  case .topBottom:
    return margin(topBottom: size)
  }
}

private let spacings: [Size] = [
  0,
  .rem(0.5),
  .rem(1.0),
  .rem(2.0),
  .rem(4.0)
]
