import Css
import Foundation
import HttpPipeline
import Models
import PointFreeRouter
import Prelude
import Tuple
import Views

func aboutResponse(_ conn: Conn<StatusLineOpen, Void>) -> Conn<ResponseEnded, Data> {
  conn
    .writeStatus(.ok)
    .respond(view: aboutView) {
      SimplePageLayoutData(
        data: [.brandon, .stephen],
        extraStyles: aboutExtraStyles,
        title: "About"
      )
    }
}
