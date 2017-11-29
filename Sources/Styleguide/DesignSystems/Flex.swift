import Css
import Prelude

public enum Class {
  public enum flex {
    /// ".flex"
    public static let flex = CssSelector.class("flex")
    /// ".flex-column"
    public static let column = CssSelector.class("flex-column")
    /// ".flex-wrap"
    public static let wrap = CssSelector.class("flex-wrap")
    /// ".flex-none"
    public static let none = CssSelector.class("flex-none")

    public static func flex(breakpoint: Breakpoint) -> CssSelector {
      return CssSelector.class("flex-\(breakpoint)")
    }

    public enum items {
      /// ".items-start"
      public static let start = CssSelector.class("items-start")
      /// ".items-end"
      public static let end = CssSelector.class("items-end")
      /// ".items-center"
      public static let center = CssSelector.class("items-center")
      /// ".items-baseline"
      public static let baseline = CssSelector.class("items-baseline")
      /// ".items-stretch"
      public static let stretch = CssSelector.class("items-stretch")
    }

    public enum `self` {
      /// ".self-start"
      public static let start = CssSelector.class("self-start")
      /// ".self-end"
      public static let end = CssSelector.class("self-end")
      /// ".self-center"
      public static let center = CssSelector.class("self-center")
      /// ".self-baseline"
      public static let baseline = CssSelector.class("self-baseline")
      /// ".self-stretch"
      public static let stretch = CssSelector.class("self-stretch")
    }

    public enum justify {
      /// ".justify-start"
      public static let start = CssSelector.class("justify-start")
      /// ".justify-end"
      public static let end = CssSelector.class("justify-end")
      /// ".justify-center"
      public static let center = CssSelector.class("justify-center")
      /// ".justify-between"
      public static let between = CssSelector.class("justify-between")
      /// ".justify-around"
      public static let around = CssSelector.class("justify-around")
    }

    public enum align {
      /// ".align-start"
      public static let start = CssSelector.class("align-start")
      /// ".align-end"
      public static let end = CssSelector.class("align-end")
      /// ".align-center"
      public static let center = CssSelector.class("align-center")
      /// ".align-between"
      public static let between = CssSelector.class("align-between")
      /// ".align-around"
      public static let around = CssSelector.class("align-around")
    }

    public static let order = (
      CssSelector.class("order-0"),
      CssSelector.class("order-1"),
      CssSelector.class("order-2"),
      CssSelector.class("order-3"),
      last: CssSelector.class("order-last")
    )
  }
}

public let flexStyles: Stylesheet =
  Breakpoint.all.map { b in
    queryOnly(screen, [minWidth(b.minSize)]) { Class.flex.flex(breakpoint: b) % display(.flex) }
    }.concat()
    <> Class.flex.flex % display(.flex)
    <> Class.flex.column % flex(direction: .column)
    <> Class.flex.wrap % flex(wrap: .wrap)
    <> Class.flex.none % flex(wrap: .none)
    <> itemStyles
    <> selfStyles
    <> justifyStyles
    <> alignContentStyles
    <> orderStyles

private let itemStyles =
       Class.flex.items.start    % align(items: .flexStart)
    <> Class.flex.items.end      % align(items: .flexEnd)
    <> Class.flex.items.center   % align(items: .center)
    <> Class.flex.items.baseline % align(items: .baseline)
    <> Class.flex.items.stretch  % align(items: .stretch)

private let selfStyles =
       Class.flex.`self`.start    % align(self: .flexStart)
    <> Class.flex.`self`.end      % align(self: .flexEnd)
    <> Class.flex.`self`.center   % align(self: .center)
    <> Class.flex.`self`.baseline % align(self: .baseline)
    <> Class.flex.`self`.stretch  % align(self: .stretch)

private let justifyStyles =
       Class.flex.justify.start % justify(content: .flexStart)
    <> Class.flex.justify.end % justify(content: .flexEnd)
    <> Class.flex.justify.center % justify(content: .center)
    <> Class.flex.justify.between % justify(content: .spaceBetween)
    <> Class.flex.justify.around % justify(content: .spaceAround)

private let alignContentStyles =
       Class.flex.align.start % align(content: .flexStart)
    <> Class.flex.align.end % align(content: .flexEnd)
    <> Class.flex.align.center % align(content: .center)
    <> Class.flex.align.between % align(content: .spaceBetween)
    <> Class.flex.align.around % align(content: .spaceAround)

private let orderStyles =
       Class.flex.order.0     % order(0)
    <> Class.flex.order.1     % order(1)
    <> Class.flex.order.2     % order(2)
    <> Class.flex.order.3     % order(3)
    <> Class.flex.order.last  % order(99999)
