import Css
import FunctionalCss
import Html
import HtmlCssSupport
import Prelude
import Styleguide
import StyleguideV2

public struct PrivacyAndTerms: HTML {
  public init() {}
  
  public var body: some HTML {
    PageHeader(title: "Privacy Policy & Terms") {
    }

    PageModule.init(theme: .content) {
      HTMLMarkdown("""
        ## Personal identification information
        We collect email addresses of registered Users and any other information voluntarily entered into forms on the Site. None of this information is sold or provided to third parties, except to provide the products and services you've requested, with your permission, or as required by law.

        ## Non-personal identification information
        We may collect non-personal identification information about Users whenever they interact with the Site, This may include: the browser name, the type of computer, the operating system, and other similar information.

        ## Web browser cookies
        The Site may use “cookies” to enhance User experience. Users may choose to set their web browser to refuse cookies, or to indicate when cookies are being sent. Note that this may cause some parts of the Site to function improperly.

        ## How we use collected information
        Point-Free, Inc. collects and uses Users personal information for the following purposes:

        * To personalize user experience: to understand how our Users as a group use the Site.
        * To improve our Site.
        * To improve customer service.
        * To process transactions: We may use the information Users provide about themselves when placing an order only to provide service to that order. We do not share this information with outside parties except to the extent necessary to provide the service.
        * To send periodic emails: The email address Users provide for order processing, will only be used to send them information and updates pertaining to their order. It may also be used to respond to their inquiries, and/or other requests or questions. If User decides to opt-in to our mailing list, they will receive emails that may include company news, updates, related product or service information, etc. If at any time the User would like to unsubscribe from receiving future emails, we include detailed unsubscribe instructions at the bottom of each email.

        ## How we protect your information
        We adopt appropriate data collection, storage and processing practices and security measures to protect against unauthorized access, alteration, disclosure or destruction of your personal information, username, password, transaction information and data stored on our Site.

        Sensitive and private data exchange between the Site and its Users happens over a SSL secured communication channel and is encrypted and protected with digital signatures.

        ## Sharing your personal information
        We do not sell, trade, or rent Users' personal identification information to others. We may share generic aggregated demographic information not linked to any personal identification information regarding visitors and users with our business partners and trusted affiliates for the purposes outlined above.

        ## Compliance with children's online privacy protection act
        Protecting the privacy of the very young is especially important. For that reason, we never collect or maintain information at our Site from those we actually know are under 13, and no part of our website is structured to attract anyone under 13.

        ## Terms of use
        Individual subscriptions are only valid for use by an individual person. Team subscriptions are only valid for use by the number of persons allotted seats. We reserve the right to cancel subscriptions at our own discretion.

        ## Changes to this privacy policy
        Point-Free, Inc. has the discretion to update this privacy policy at any time. When we do, we will revise the updated date at the bottom of this page.

        ## Contacting us
        Questions about this policy can be sent to support@pointfree.co.

        This document was last updated on January 13, 2020.
        """)
      .color(.offBlack.dark(.offWhite))
    }
  }
}
