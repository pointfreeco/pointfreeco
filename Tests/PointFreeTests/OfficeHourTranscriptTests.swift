#if canImport(Testing)
  import Foundation
  import Models
  import Testing

  @testable import Views

  @Suite
  struct OfficeHourTranscriptTests {
    func question(_ text: String, answeredAt seconds: Int) -> OfficeHourQuestion {
      OfficeHourQuestion(
        id: .init(rawValue: UUID()),
        answeredAtSeconds: .init(rawValue: seconds),
        question: text,
        userID: nil
      )
    }

    @Test
    func sectionsFromTimestampsHeadingsAndQuestions() {
      let transcript = """
        Welcome everybody to the very first office hours.

        @T(0:30)
        Before we get into questions, a quick announcement.

        ## Announcements

        We released a new version of the library this week.

        @T(2:00)
        OK, let's get into the questions.

        @T(5:00)
        Great question. So the deal with @Feature is...

        @T(9:00)
        Next up. Yes, we do plan on supporting that.
        """

      let sections = officeHourTranscriptSections(
        transcript: transcript,
        questions: [
          question("What is the deal with `@Feature`?", answeredAt: 290),
          question("Will you support Linux?", answeredAt: 530),
          question("Never reached in transcript?", answeredAt: 9_999),
        ]
      )

      #expect(sections.count == 5)

      guard case .introduction = sections[0].kind else {
        Issue.record("expected introduction")
        return
      }
      #expect(sections[0].body.contains("Welcome everybody"))
      #expect(sections[0].body.contains("quick announcement"))
      #expect(sections[0].body.contains("@T(0:30)"))

      guard case .manual(let title) = sections[1].kind else {
        Issue.record("expected manual section")
        return
      }
      #expect(title == "Announcements")
      #expect(sections[1].seconds == 30)
      #expect(sections[1].body.contains("new version of the library"))
      #expect(sections[1].body.contains("let's get into the questions"))

      guard case .question(let first) = sections[2].kind else {
        Issue.record("expected question section")
        return
      }
      #expect(first.question == "What is the deal with `@Feature`?")
      #expect(sections[2].seconds == 290)
      #expect(sections[2].body.hasPrefix("@T(5:00)"))
      #expect(sections[2].body.contains("the deal with @Feature is"))

      guard case .question(let second) = sections[3].kind else {
        Issue.record("expected question section")
        return
      }
      #expect(second.question == "Will you support Linux?")
      #expect(sections[3].body.contains("we do plan on supporting that"))

      guard case .question(let third) = sections[4].kind else {
        Issue.record("expected trailing question section")
        return
      }
      #expect(third.question == "Never reached in transcript?")
      #expect(sections[4].body.isEmpty)
    }

    @Test
    func flatTranscriptWithNoMarkersOrQuestions() {
      let sections = officeHourTranscriptSections(
        transcript: "Just one big blob of text.\n\nWith two paragraphs.",
        questions: []
      )
      #expect(sections.count == 1)
      guard case .introduction = sections[0].kind else {
        Issue.record("expected introduction")
        return
      }
      #expect(sections[0].body.contains("big blob"))
      #expect(sections[0].body.contains("two paragraphs"))
    }

    @Test
    func questionsWithoutTimestampsAreIgnored() {
      let sections = officeHourTranscriptSections(
        transcript: "@T(1:00)\nSome discussion.",
        questions: [
          OfficeHourQuestion(
            id: .init(rawValue: UUID()),
            question: "Unanswered timestamp-less question",
            userID: nil
          )
        ]
      )
      #expect(sections.count == 1)
    }
  }
#endif
