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
}

extension Class {
  public static func padding(_ data: [Breakpoint: [Side: Int]]) -> CssSelector {
    return selector(data, whitespace: .padding)
  }

  public static func margin(_ data: [Breakpoint: [Side: Int]]) -> CssSelector {
    return selector(data, whitespace: .margin)
  }
}

public let spacingStyles =
  responsivePaddingStyles
    <> responsiveMarginStyles

extension Side {
  fileprivate static let allSides: [Side] = [.bottom, .left, .right, .top]
}

private enum Whitespace: String {
  case margin = "m"
  case padding = "p"

  static let all: [Whitespace] = [.margin, .padding]
}

private let responsivePaddingStyles =
  Breakpoint.all.compactMap { breakpoint in
    breakpoint.querySelfAndBigger(only: screen) {
      Side.allSides.flatMap { side in
        spacings.enumerated().map { n, size in
          Class.padding([breakpoint: [side: n]]) % paddingStyle(side: side, size: size)
          }
        }
        .concat()
      }
    }
    .concat()

private let responsiveMarginStyles =
  Breakpoint.all.compactMap { breakpoint in
    breakpoint.querySelfAndBigger(only: screen) {
      Side.allSides.flatMap { side in
        spacings.enumerated().map { n, size in
          Class.margin([breakpoint: [side: n]]) % marginStyle(side: side, size: size)
        }
        }
        .concat()
      }
    }
    .concat()

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

private func selector(_ data: [Breakpoint: [Side: Int]], whitespace: Whitespace) -> CssSelector {
  let classes = data
    .sorted(by: { $0.key.rawValue < $1.key.rawValue })
    .flatMap { breakpoint, sides in
      sides
        .sorted(by: { $0.key.rawValue < $1.key.rawValue })
        .map { side, n in
          selector(side: side, breakpoint: breakpoint, n: n, whitespace: whitespace)
      }
  }
  return classes.dropFirst().reduce(classes.first ?? .class("not-found"), |)
}

private func selector(side: Side, breakpoint: Breakpoint, n: Int, whitespace: Whitespace) -> CssSelector {
  switch side {
  case .all:
    return selector(side: .left, breakpoint: breakpoint, n: n, whitespace: whitespace)
      | selector(side: .right, breakpoint: breakpoint, n: n, whitespace: whitespace)
      | selector(side: .top, breakpoint: breakpoint, n: n, whitespace: whitespace)
      | selector(side: .bottom, breakpoint: breakpoint, n: n, whitespace: whitespace)

  case .bottom, .left, .top, .right:
    return CssSelector.class("\(breakpoint.rawValue)-\(whitespace.rawValue)\(side.rawValue)\(n)")

  case .leftRight:
    return selector(side: .left, breakpoint: breakpoint, n: n, whitespace: whitespace)
      | selector(side: .right, breakpoint: breakpoint, n: n, whitespace: whitespace)

  case .topBottom:
    return  selector(side: .top, breakpoint: breakpoint, n: n, whitespace: whitespace)
      | selector(side: .bottom, breakpoint: breakpoint, n: n, whitespace: whitespace)
  }
}
