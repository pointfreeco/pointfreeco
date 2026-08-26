#if canImport(Testing)
  import Html
  import StyleguideV2
  import Testing

  @Suite
  struct MarkdownTests {
    @Test
    func tableAlignment() {
      let html = HTMLMarkdown(
        trusted: """
        | User         | Is Admin |    ID |
        | :----------- | :------: | ----: |
        | Blob         |   true   |     1 |
        | Blob Senior  |   true   |     2 |
        | Blob Junior  |  false   |     3 |
        | Blob Esquire |  false   |     4 |
        """
      )
      .render()
      let expected = """

        <pf-markdown class="display-ix08W2">
          <pf-vstack class="align-items-msN8p3 display-BvS8W3 flex-direction-7gclL max-width-C8uWv row-gap-NKv2f3">
            <table class="content-xD6dy1 margin-left-rhxaL1">
              <thead>
                <tr>
                  <th align="left">User
                  </th>
                  <th align="center">Is Admin
                  </th>
                  <th align="right">ID
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td align="left">Blob
                  </td>
                  <td align="center">true
                  </td>
                  <td align="right">1
                  </td>
                </tr>
                <tr>
                  <td align="left">Blob Senior
                  </td>
                  <td align="center">true
                  </td>
                  <td align="right">2
                  </td>
                </tr>
                <tr>
                  <td align="left">Blob Junior
                  </td>
                  <td align="center">false
                  </td>
                  <td align="right">3
                  </td>
                </tr>
                <tr>
                  <td align="left">Blob Esquire
                  </td>
                  <td align="center">false
                  </td>
                  <td align="right">4
                  </td>
                </tr>
              </tbody>
            </table>
          </pf-vstack>
        </pf-markdown>
        """
      #expect(String(decoding: html, as: UTF8.self) == expected)
    }

    @Test
    func tableSpan() {
      let html = HTMLMarkdown(
        trusted: """
        | User         | Is Admin |    ID |
        | ------------ | -------- | ----- |
        | Blob                   ||     1 |
        | ^                      ||     2 |
        | Blob Junior  |  false   |     3 |
        | Blob Esquire |  false   |     4 |
        """
      )
      .render()
      let expected = """

        <pf-markdown class="display-ix08W2">
          <pf-vstack class="align-items-msN8p3 display-BvS8W3 flex-direction-7gclL max-width-C8uWv row-gap-NKv2f3">
            <table class="content-xD6dy1 margin-left-rhxaL1">
              <thead>
                <tr>
                  <th>User
                  </th>
                  <th>Is Admin
                  </th>
                  <th>ID
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td colspan="2" rowspan="2">Blob
                  </td>
                  <td>1
                  </td>
                </tr>
                <tr>
                  <td>2
                  </td>
                </tr>
                <tr>
                  <td>Blob Junior
                  </td>
                  <td>false
                  </td>
                  <td>3
                  </td>
                </tr>
                <tr>
                  <td>Blob Esquire
                  </td>
                  <td>false
                  </td>
                  <td>4
                  </td>
                </tr>
              </tbody>
            </table>
          </pf-vstack>
        </pf-markdown>
        """
      #expect(String(decoding: html, as: UTF8.self) == expected)
    }

    @Test
    func plainText() {
      let markdown = """
        What is the deal with **this** and `@Feature`?

        ```swift
        struct Login {
          var email: String
        }
        ```

        And [what about](https://example.com) *links*?
        """
      #expect(
        HTMLMarkdown.plainText(markdown) == """
          What is the deal with this and @Feature? struct Login { var email: String } \
          And what about links?
          """
      )
    }

    @Test
    func plainTextLimit() {
      let markdown = String(repeating: "A paragraph of text.\n\n", count: 1_000)
      let text = HTMLMarkdown.plainText(markdown, limit: 50)
      #expect(text.count == 50)
      #expect(text.hasPrefix("A paragraph of text. A paragraph of text."))
    }
  }
#endif
