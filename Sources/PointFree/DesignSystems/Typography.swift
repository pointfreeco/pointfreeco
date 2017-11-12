import Css
import Prelude

let htmlStyles = html % (
  fontSize(.px(16))
    <> fontFamily(["-apple-system", "Helvetica Neue", "Helvetica", "Arial", "sans-serif"])
    <> lineHeight(1.3)
)

let headerStyles =
  ".h1" | ".h2" | ".h3" | ".h4" | ".h5" | ".h6" 

let typography: Stylesheet =
  htmlStyles


//
//      html {
//        font-size: 16px;
//        font-family: -apple-system, "Helvetica Neue", Helvetica, Arial, sans-serif;
//        line-height: 1.3;
//      }
//      .h1, .h2, .h3, .h4, .h5, .h6 {
//        font-weight: 700;
//      }
//      .h1, .h2, .h3, .h4 {
//        line-height: 1.2;
//      }
//      .h1 {
//        font-size: 3.998rem;
//      }
//      .h2 {
//        font-size: 2.827rem;
//      }
//      .h3 {
//        font-size: 1.999rem;
//      }
//      .h4 {
//        font-size: 1.414rem;
//      }
//      .h5 {
//        font-size: 1.0rem;
//      }
//      .h6 {
//        font-size: 0.707rem;
//        text-transform: uppercase;
//        letter-spacing: 0.54pt;
//      }

