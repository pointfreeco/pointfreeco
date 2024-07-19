import Either
import EmailAddress
import IssueReporting

extension IssueReporter where Self == EmailReporter {
  public static var adminEmail: Self {
    email(adminEmails)
  }

  public static func email(_ emails: [EmailAddress]) -> Self {
    Self(emails: emails)
  }
}

public struct EmailReporter: IssueReporter {
  let emails: [EmailAddress]

  public init(emails: [EmailAddress]) {
    self.emails = emails
  }

  public func reportIssue(
    _ message: @autoclosure () -> String?,
    fileID: StaticString,
    filePath: StaticString,
    line: UInt,
    column: UInt
  ) {
    Task { [message = message()] in
      try await send(
        message: message,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  }

  public func reportIssue(
    _ error: any Error,
    _ message: @autoclosure () -> String?,
    fileID: StaticString,
    filePath: StaticString,
    line: UInt,
    column: UInt
  ) {
    Task { [message = message()] in
      try await send(
        error: error,
        message: message,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  }

  private func send(
    error: (any Error)? = nil,
    message: String?,
    fileID: StaticString,
    filePath: StaticString,
    line: UInt,
    column: UInt
  ) async throws {
    let subjectAndBody = (message ?? "").split(separator: "\n", maxSplits: 1)
    let count = subjectAndBody.count
    let subject = count > 0 ? subjectAndBody[0] : ""
    var body = count > 1 ? String(subjectAndBody[1]) : ""
    body.append(
      """


        Issue reported at:
          \(fileID):\(line):\(column)
      """
    )
    var errorDump = ""
    if let error {
      dump(error, to: &errorDump, indent: 4)
      body.append(
        """
        

          Error:
        \(errorDump)
        """
      )
    }
    try await sendEmail(
      to: emails,
      subject: "[PointFree Error] \(subject.isEmpty ? "Untitled" : subject)",
      content: inj1(body)
    )
  }
}
