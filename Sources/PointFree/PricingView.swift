import Html
import Prelude
import Styleguide

let _pricingView = View<Prelude.Unit> { _ in
  gridRow([`class`([Class.pf.colors.bg.purple150, Class.grid.center(.desktop), Class.padding([.desktop: [.topBottom: 5]])])], [

    gridColumn(sizes: [.desktop: 6], [], [

      h2([`class`([Class.pf.colors.fg.white, Class.pf.type.title2])], ["Subscribe to Point-Free"]),

      p(
        [`class`([Class.pf.colors.fg.green])],
        ["Unlock full episodes and receive new updates every week."]
      )

      ] + pricingTabsView.view(unit))

    ])
}

private let pricingTabsView = View<Prelude.Unit> { _ in
  []
}
