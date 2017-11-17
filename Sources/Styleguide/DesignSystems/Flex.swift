import Css
import Prelude

public enum FlexClass {
  public static let flex = CssSelector.class(".flex")
  public static let column = CssSelector.class(".flex-column")
  public static let wrap = CssSelector.class(".flex-wrap")
  public static let none = CssSelector.class(".flex-none")

  public enum items {
    public static let start = CssSelector.class(".items-start")
    public static let end = CssSelector.class(".items-end")
    public static let center = CssSelector.class(".items-center")
    public static let baseline = CssSelector.class(".items-baseline")
    public static let stretch = CssSelector.class(".items-stretch")
  }
}

public let flexStyles: Stylesheet =
  FlexClass.flex % display(.flex)
    <> queryOnly(screen, [minWidth(Breakpoint.sm.minSize)]) { FlexClass.flex % display(.flex) }
    <> queryOnly(screen, [minWidth(Breakpoint.md.minSize)]) { FlexClass.flex % display(.flex) }
    <> queryOnly(screen, [minWidth(Breakpoint.lg.minSize)]) { FlexClass.flex % display(.flex) }
    <> FlexClass.column % flex(direction: .column)
    <> FlexClass.wrap % flex(wrap: .wrap)
    <> FlexClass.none % flex(wrap: .none)
    <> itemStyles
    <> selfStyles
    <> justifyStyles
    <> alignContentStyles
    <> orderStyles

private let itemStyles =
  FlexClass.items.start % align(items: .flexStart)
    <> FlexClass.items.end % align(items: .flexEnd)
    <> FlexClass.items.center % align(items: .center)
    <> FlexClass.items.baseline % align(items: .baseline)
    <> FlexClass.items.stretch % align(items: .stretch)

private let selfStyles =
  ".self-start" % align(self: .flexStart)
    <> ".self-end" % align(self: .flexEnd)
    <> ".self-center" % align(self: .center)
    <> ".self-baseline" % align(self: .baseline)
    <> ".self-stretch" % align(self: .stretch)

private let justifyStyles =
  ".justify-start" % justify(content: .flexStart)
    <> ".justify-end" % justify(content: .flexEnd)
    <> ".justify-center" % justify(content: .center)
    <> ".justify-between" % justify(content: .spaceBetween)
    <> ".justify-around" % justify(content: .spaceAround)

private let alignContentStyles =
  ".self-start" % align(content: .flexStart)
    <> ".self-end" % align(content: .flexEnd)
    <> ".self-center" % align(content: .center)
    <> ".self-baseline" % align(content: .spaceBetween)
    <> ".self-stretch" % align(content: .spaceAround)

private let orderStyles =
  ".order-0" % order(0)
    <> ".order-1" % order(1)
    <> ".order-2" % order(2)
    <> ".order-3" % order(3)
    <> ".order-last" % order(99999)
