import Css
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple

let aboutResponse =
  writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: aboutView,
      layoutData: { currentUser in
        SimplePageLayoutData(currentUser: currentUser, data: unit, title: "About Us")
    }
)

private let aboutView = View<Prelude.Unit> { _ in
  gridRow([
    gridColumn(sizes: [.mobile: 12], [
      div([`class`([Class.padding([.mobile: [.all: 4]])])], [

        h1([`class`([Class.pf.type.title2])], ["About"]),
        p(["""
           Point-Free is a weekly video series discussing functional programming and the Swift programming
           language. Episodes will be between 20 and 30 minutes long, covering an important
           """]),

        h1([`class`([Class.pf.type.title3, Class.padding([.mobile: [.top: 2]])])], ["Open Source"]),
        p(["""
           We knew we wanted to build this site using server-side Swift from the beginning, and wanted it
           to be as functional as possible. This meant we had to build almost everything from scratch.
           """]),

        h1([`class`([Class.pf.type.title3, Class.padding([.mobile: [.top: 2]])])], ["The hosts"]),
        p([
          img(src: "https://pbs.twimg.com/profile_images/441388783624155136/LSggwlQ1_400x400.jpeg", alt: "Photo of Brandon Williams", [`class`([Class.layout.left, Class.border.circle]), style(width(.px(200)))]),

          """
          lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum
          lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum
          lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum
          lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum
          lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum
          lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum lorem ipsum
          """
          ]),


        img(src: "https://pbs.twimg.com/profile_images/444191920/Photo_on_2009-09-29_at_21.20_400x400.jpg", alt: "Photo of Brandon Williams", [`class`([Class.layout.right, Class.border.circle]), style(width(.px(200)))]),
        ])
      ])
    ])
}
