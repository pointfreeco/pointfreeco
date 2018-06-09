import Css
import Prelude

public enum TypeScale: String {
  case r4
  case r3
  case r2
  case r1_5
  case r1_25
  case r1
  case r0_875
  case r0_75

  fileprivate var size: Size {
    switch self {
    case .r4:
      return .rem(4)
    case .r3:
      return .rem(3)
    case .r2:
      return .rem(2)
    case .r1_5:
      return .rem(1.5)
    case .r1_25:
      return .rem(1.25)
    case .r1:
      return .rem(1)
    case .r0_875:
      return .rem(0.875)
    case .r0_75:
      return .rem(0.75)
    }
  }

  fileprivate static let allTypeScales: [TypeScale] = [.r4, .r3, .r2, .r1_5, .r1_25, .r1, .r0_875, .r0_75]
}

extension Class {
  public static let h1 = CssSelector.class("h1")
  public static let h2 = CssSelector.class("h2")
  public static let h3 = CssSelector.class("h3")
  public static let h4 = CssSelector.class("h4")
  public static let h5 = CssSelector.class("h5")
  public static let h6 = CssSelector.class("h6")

  public static func typeScale(_ data: [Breakpoint: TypeScale]) -> CssSelector {
    let selectors = data
      .sorted(by: { $0.key.rawValue < $1.key.rawValue })
      .map { breakpoint, typeScale in
        selector(breakpoint: breakpoint, typeScale: typeScale)
    }
    return selectors
      .dropFirst()
      .reduce(selectors.first ?? .class("not-found"), |)
  }
}

private func selector(breakpoint: Breakpoint, typeScale: TypeScale) -> CssSelector {
  return CssSelector.class("ts-\(breakpoint.rawValue)-\(typeScale.rawValue)")
}

public let typescale =
  Class.h1 % fontSize(.rem(4))         // 64  56
    <> Class.h2 % fontSize(.rem(3))    // 48  42
    <> Class.h3 % fontSize(.rem(2))    // 32  28
    <> Class.h4 % fontSize(.rem(1.5))  // 24  21
    <> Class.h5 % fontSize(.rem(1.0))  // 16  14
    <> Class.h6 % fontSize(.rem(0.75)) // 12  11
    <> responsiveFontSizes

private let responsiveFontSizes =
  Breakpoint.all.map { breakpoint in
    breakpoint.querySelfAndBigger(only: screen) {
      TypeScale.allTypeScales.map { typeScale in
        Class.typeScale([breakpoint: typeScale]) % fontSize(typeScale.size)
        }
        .concat()
    }
    }
    .concat()
