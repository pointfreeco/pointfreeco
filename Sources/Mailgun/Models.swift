import PointFreePrelude

public struct SendEmailResponse: Decodable {
  public let id: String
  public let message: String

  public init(id: String, message: String) {
    self.id = id
    self.message = message
  }
}

public enum Tracking: String {
  case no
  case yes
}

public enum TrackingClicks: String {
  case yes
  case no
  case htmlOnly = "htmlonly"
}

public enum TrackingOpens: String {
  case yes
  case no
  case htmlOnly = "htmlonly"
}

public struct Email {
  public var from: EmailAddress
  public var to: [EmailAddress]
  public var cc: [EmailAddress]? = nil
  public var bcc: [EmailAddress]? = nil
  public var subject: String
  public var text: String?
  public var html: String?
  public var testMode: Bool? = nil
  public var tracking: Tracking? = nil
  public var trackingClicks: TrackingClicks? = nil
  public var trackingOpens: TrackingOpens? = nil
  public var domain: String
  public var headers: [(String, String)] = []

  public init(
    from: EmailAddress,
    to: [EmailAddress],
    cc: [EmailAddress]? = nil,
    bcc: [EmailAddress]? = nil,
    subject: String,
    text: String?,
    html: String?,
    testMode: Bool? = nil,
    tracking: Tracking? = nil,
    trackingClicks: TrackingClicks? = nil,
    trackingOpens: TrackingOpens? = nil,
    domain: String,
    headers: [(String, String)] = []) {
    self.from = from
    self.to = to
    self.cc = cc
    self.bcc = bcc
    self.subject = subject
    self.text = text
    self.html = html
    self.testMode = testMode
    self.tracking = tracking
    self.trackingClicks = trackingClicks
    self.trackingOpens = trackingOpens
    self.domain = domain
    self.headers = headers
  }
}
