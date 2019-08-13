import HttpPipeline
import Foundation
import Models
import PointFreePrelude
import PointFreeRouter
import Prelude
import Tuple
import View
import Views

public let subscribeConfirmation: Middleware<
  StatusLineOpen,
  ResponseEnded,
  Tuple3<User?, SubscriberState, Route>,
  Data
  > =
  writeStatus(.ok)
    >=> respond(text: "Subscribe!")
