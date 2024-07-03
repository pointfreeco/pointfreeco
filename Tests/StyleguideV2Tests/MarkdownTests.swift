#if canImport(Testing)
  import Html
  import StyleguideV2
  import Testing

  @Suite
  struct MarkdownTests {
    @Test
    func tableAlignment() {
      let html = HTMLMarkdown(
        """
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

        <pf-markdown class="display-0">
          <table>
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
        </pf-markdown>
        """
      #expect(String(decoding: html, as: UTF8.self) == expected)
    }

    @Test
    func tableSpan() {
      let html = HTMLMarkdown(
        """
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

        <pf-markdown class="display-0">
          <table>
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
        </pf-markdown>
        """
      #expect(String(decoding: html, as: UTF8.self) == expected)
    }
  }
#endif
