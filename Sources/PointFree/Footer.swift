import Css
import Html
import HtmlCssSupport
import Styleguide
import Prelude

private let footerClasses = [
  Class.grid.row,
  Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]]),
  Class.pf.colors.bg.white
]

let footerView =
  dividerView
    <> (curry(footer)([`class`(footerClasses)]) >>> pure
      <¢> footerInfoColumnsView
      <> (gridColumn(sizes: [.mobile: 12]) >>> pure
        <¢> legalView
      )
)

private let footerInfoColumnsView =
       pointFreeView    .map(gridColumn(sizes: [.mobile: 12, .desktop: 6]) >>> pure)
    <> accountColumnView.map(gridColumn(sizes: [.mobile: 4,  .desktop: 2]) >>> pure)
    <> contentColumnView.map(gridColumn(sizes: [.mobile: 4,  .desktop: 2]) >>> pure)
    <> moreColumnView   .map(gridColumn(sizes: [.mobile: 4,  .desktop: 2]) >>> pure)

private let legalView = View<Prelude.Unit> { _ in
  p([`class`([Class.pf.colors.fg.gray400, Class.type.align.center, Class.h6, Class.padding([.mobile: [.top: 2]])])], [
    "The content of this site is license under ",
    a([href("https://creativecommons.org/licenses/by-nc-sa/4.0/")], ["CC BY-NC-SA 4.0"]),
    ", and the underlying ",
    a([href(gitHubUrl(to: .repo(.pointfreeco)))], ["source code"]),
    " to run this site is licensed under the ",
    a([href(gitHubUrl(to: .license))], ["MIT license"]),
    ". Point-Free, Inc 2018."
    ])
}

private let pointFreeView = View<Prelude.Unit> { _ in
  div([`class`([Class.padding([.mobile: [.right: 4]])])], [
    h4([`class`([Class.h4, Class.margin([.mobile: [.bottom: 0]])])], [
      a([href(path(to: .secretHome))], ["Point-Free"])
      ]),
    p([
      "A weekly video series on functional programming and the Swift programming language. Hosted by ",
      a(
        [href(twitterUrl(to: .mbrandonw)), `class`([Class.type.textDecorationNone])],
        ["Brandon Williams"]
      ),
      " and ",
      a(
        [href(twitterUrl(to: .stephencelis)), `class`([Class.type.textDecorationNone])],
        [.text(unsafeUnencodedString("Stephen&nbspCelis"))]
      ),
      "."
      ])
    ])
}

private let contentColumnView = View<Prelude.Unit> { _ in
  div([
    h5([`class`([Class.h5])], ["Content"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href(path(to: .secretHome))], ["Videos"])]),
      li([a([href("http://www.fewbutripe.com")], ["Few, but ripe…"])]),
      li([a([href("http://www.stephencelis.com")], ["Stephen Celis"])]),
      ])
    ])
}

private let accountColumnView = View<Prelude.Unit> { _ in
  div([
    h5([`class`([Class.h5])], ["Account"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href("#")], ["Subscribe"])]),
      li([a([href(path(to: .pricing(nil, nil)))], ["Pricing"])]),
      ])
    ])
}

private let moreColumnView = View<Prelude.Unit> { _ in
  div([
    h5([`class`([Class.h5])], ["More"]),
    ol([`class`([Class.type.list.reset])], [
      li([a([href(twitterUrl(to: .pointfreeco))], ["Twitter"])]),
      li([a([href(gitHubUrl(to: .organization))], ["GitHub"])]),
      li([a([mailto("support@pointfree.co")], ["Contact us"])]),
      ])
    ])
}
