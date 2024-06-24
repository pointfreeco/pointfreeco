import Html
import StyleguideV2
import Testing

struct HTMLTests {
  @Test
  func basics() {
    let node = Node {
      div {
        a {}
          .attribute("href", "http://pointfree.co")
          .class("m-pt3")
          .class("m-pb3")
      }
      a {}
      if Bool.random() {
        a {}
      }
      for _ in 1...3 {
        a {}
      }
    }

    print(render(node))
  }

  @Test
  func viewBody() {
    struct MyPage: NodeView {
      var body: Node {
        div {
          a {}
            .attribute("href", "http://pointfree.co")
            .class("m-pt3")
            .class("m-pb3")
        }
        a {}
        if Bool.random() {
          a {}
        }
        for _ in 1...3 {
          a {}
        }
      }
    }

    print(type(of: MyPage().body))

    print(MyPage().render())
  }
}
