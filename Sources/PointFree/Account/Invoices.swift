import Css
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Optics
import Prelude
import Styleguide
import Tuple

// MARK: Middleware

let invoicesResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: invoicesView,
      layoutData: { subscription, currentUser, subscriberState, afterInvoiceId in
        SimplePageLayoutData(
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (subscription, currentUser, afterInvoiceId),
          title: "Invoice history"
        )
    }
)

let invoiceResponse =
  filterMap(require1 >>> pure, or: loginAndRedirect)
    <<< requireStripeSubscription
    <| writeStatus(.ok)
    >-> map(lower)
    >>> respond(
      view: invoiceView,
      layoutData: { subscription, currentUser, subscriberState, invoiceId in
        SimplePageLayoutData(
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: (subscription, currentUser, invoiceId),
          title: "Invoice"
        )
    }
)

// MARK: Views

let invoicesView = View<(Stripe.Subscription, Database.User, Stripe.Invoice.Id?)> { subscription, currentUser, seatsTaken -> Node in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        []
      )
      ])
    ])
}

let invoiceView = View<(Stripe.Subscription, Database.User, Stripe.Invoice.Id)> { subscription, currentUser, seatsTaken -> Node in

  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        []
      )
      ])
    ])
}
