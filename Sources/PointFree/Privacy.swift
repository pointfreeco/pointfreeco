import Css
import CssReset
import Either
import Foundation
import Html
import HtmlCssSupport
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import Styleguide
import Tuple

private let title = "Privacy Policy"

let privacyResponse: Middleware<StatusLineOpen, ResponseEnded, Tuple3<Database.User?, SubscriberState, Route?>, Data> =
  writeStatus(.ok)
    >=> map(lower)
    >>> respond(
      view: privacyView,
      layoutData: { currentUser, subscriberState, currentRoute in
        SimplePageLayoutData(
          currentRoute: currentRoute,
          currentSubscriberState: subscriberState,
          currentUser: currentUser,
          data: unit,
          title: title
        )
    }
)

private let privacyView = View<Prelude.Unit> { _ in
  gridRow([
    gridColumn(sizes: [.mobile: 12, .desktop: 8], [style(margin(leftRight: .auto))], [
      div(
        [`class`([Class.padding([.mobile: [.all: 3], .desktop: [.all: 4]])])],
        [h1([`class`([Class.pf.type.responsiveTitle2])], [text(title)])]
          <> privacyPolicy
          <> [
            p(
              [`class`([Class.padding([.mobile: [.top: 2]])])],
              ["This document was last updated on January 7, 2018."]
            )
        ]
      )
      ])
    ])
}

private let privacyPolicy =
  personalIdentificationInformation
    <> nonPersonalIdentificationInformation
    <> webBrowserCookies
    <> howWeUseCollectedInformation
    <> howWeProtectYourInformation
    <> sharingYourPersonalInformation
    <> complianceWithChildrensOnlinePrivacyProtectionAct
    <> changesToThisPrivacyPolicy
    <> contactingUs

private let personalIdentificationInformation = [
  h2(
    [`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])],
    ["Personal identification information"]),
  p([
    """
    We collect email addresses of registered Users and any other information voluntarily entered into
    forms on the Site. None of this information is sold or provided to third parties, except to provide
    the products and services you've requested, with your permission, or as required by law.
    """]),
]

private let nonPersonalIdentificationInformation = [
  h2(
    [`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])],
    ["Non-personal identification information"]),
  p([
    """
    We may collect non-personal identification information about Users whenever they interact with the
    Site, This may include: the browser name, the type of computer, the operating system, and other
    similar information.
    """]),
]

private let webBrowserCookies = [
  h2(
    [`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])],
    ["Web browser cookies"]),
  p([
    """
    The Site may use “cookies” to enhance User experience. Users may choose to set their web browser to
    refuse cookies, or to indicate when cookies are being sent. Note that this may cause some parts of
    the Site to function improperly.
    """]),
]

private let howWeUseCollectedInformation = [
  h2(
    [`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])],
    ["How we use collected information"]),
  p([
    """
    Point-Free, Inc. collects and uses Users personal information for the following purposes:
    """]),
  ol([
    li(["To personalize user experience: to understand how our Users as a group use the Site."]),
    li(["To improve our Site."]),
    li(["To improve customer service."]),
    li([
      """
      To process transactions: We may use the information Users provide about themselves when placing
      an order only to provide service to that order. We do not share this information with outside
      parties except to the extent necessary to provide the service.
      """]),
    li([
      """
      To send periodic emails: The email address Users provide for order processing, will only be used
      to send them information and updates pertaining to their order. It may also be used to respond to
      their inquiries, and/or other requests or questions. If User decides to opt-in to our mailing
      list, they will receive emails that may include company news, updates, related product or service
      information, etc. If at any time the User would like to unsubscribe from receiving future emails,
      we include detailed unsubscribe instructions at the bottom of each email.
      """]),
    ]),
]

private let howWeProtectYourInformation = [
  h2(
    [`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])],
    ["How we protect your information"]),
  p([
    """
    We adopt appropriate data collection, storage and processing practices and security measures to
    protect against unauthorized access, alteration, disclosure or destruction of your personal
    information, username, password, transaction information and data stored on our Site.
    """]),
  p([
    """
    Sensitive and private data exchange between the Site and its Users happens over a SSL secured
    communication channel and is encrypted and protected with digital signatures.
    """]),
]

private let sharingYourPersonalInformation = [
  h2(
    [`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])],
    ["Sharing your personal information"]),
  p([
    """
    We do not sell, trade, or rent Users' personal identification information to others. We may share
    generic aggregated demographic information not linked to any personal identification information
    regarding visitors and users with our business partners and trusted affiliates for the purposes
    outlined above.
    """]),
]

private let complianceWithChildrensOnlinePrivacyProtectionAct = [
  h2([`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])], ["Compliance with children's online privacy protection act"]),
  p([
    """
    Protecting the privacy of the very young is especially important. For that reason, we never collect
    or maintain information at our Site from those we actually know are under 13, and no part of our
    website is structured to attract anyone under 13.
    """]),
]

private let changesToThisPrivacyPolicy = [
  h2([`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])], ["Changes to this privacy policy"]),
  p([
    """
    Point-Free, Inc. has the discretion to update this privacy policy at any time. When we do, we will
    revise the updated date at the bottom of this page.
    """]),
]

private let contactingUs = [
  h2([`class`([Class.pf.type.responsiveTitle3, Class.padding([.mobile: [.top: 2]])])], ["Contacting us"]),
  p([
    "Questions about this policy can be sent to ",
    a([mailto("support@pointfree.co")], ["support@pointfree.co"]),
    "."]),
]
