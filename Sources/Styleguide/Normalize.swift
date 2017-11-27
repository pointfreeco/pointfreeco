@testable import Css
import Prelude

public let normalizeStyles: Stylesheet =
  normalizeHtml
    <> normalizeBody
    <> normalizeDisplayBlock
    <> normalizeH1
    <> normalizeFigure
    <> normalizeHr
    <> normalizePre
    <> noramlizeA
    <> normalizeAbbr
    <> normalizeWeights
    <> normalizeStuff
    <> normalizeForms

private let normalizeHtml =
  lineHeight(1.15)
    <> key("-ms-text-size-adjust", Size.pct(100))
    <> key("-webkit-text-size-adjust", Size.pct(100))

private let normalizeBody =
  body % margin(all: 0)

private let normalizeDisplayBlock =
  (article | aside | footer | header | nav | section | figcaption | figure | main)
    % display(.block)

private let normalizeH1 =
  h1 % (
    fontSize(.rem(2))
      <> margin(topBottom: .rem(0.67), leftRight: 0)
)

private let normalizeFigure =
  figure % margin(topBottom: .em(1), leftRight: .px(40))

private let normalizeHr =
  hr % (
    boxSizing(.contentBox)
      <> height(0)
      <> overflow(.visible)
)

private let normalizePre =
  pre % (
    fontFamily(["monospace"])
      <> fontSize(.em(1))
)

private let noramlizeA =
  a % (
    backgroundColor(.transparent)
      <> key("-webkit-text-decoration-skip", "objects")
)

private let normalizeAbbr =
  abbr["title"] % (
    borderColor(bottom: .none)
      <> borderStyle(bottom: .none)
      <> borderWidth(bottom: .none)
      // TODO: add to swift-web
      <> key("text-decoration", "underline")
      <> key("text-decoration", "underline dotted")
)


private let normalizeWeights =
  (b | strong) % fontWeight(.inherit)
    <> (b | strong) % fontWeight(.bolder)

private let normalizeStuff =
  code % (
    fontFamily(["monospace"])
      <> fontSize(.em(1))
    )
    <> (sub | sup) % (
      fontSize(.pct(75))
        <> lineHeight(0)
        <> position(.relative)
        <> verticalAlign(.baseline)
    )
    <> sub % bottom(.em(-0.25))
    <> sup % top(.em(-0.5))
    <> (audio | video) % display(.inlineBlock)
    <> img % borderStyle(all: .none)
    <> (svg & .pseudo(.not(.pseudo(.root)))) % overflow(.hidden)

let normalizeForms =
  (button | input | optgroup | select | textarea) % (
    fontFamily(["sans-serif"])
      <> fontSize(.pct(100))
      <> lineHeight(1.15)
      <> margin(all: 0)
    )
    <> (button | input) % overflow(.visible)
    <> (button | select) % textTransform(.none)
    <> (button
      | (html ** CssSelector.star["type"=="button"])
      | CssSelector.star["type"=="reset"]
      | CssSelector.star["type"=="submit"]) % key("-webkit-appearance", "button")

//let normalizeButtons =



//
///**
// * Remove the inner border and padding in Firefox.
// */
//
//button::-moz-focus-inner,
//[type="button"]::-moz-focus-inner,
//[type="reset"]::-moz-focus-inner,
//[type="submit"]::-moz-focus-inner {
//  border-style: none;
//  padding: 0;
//}
//
///**
// * Restore the focus styles unset by the previous rule.
// */
//
//button:-moz-focusring,
//[type="button"]:-moz-focusring,
//[type="reset"]:-moz-focusring,
//[type="submit"]:-moz-focusring {
//  outline: 1px dotted ButtonText;
//}
//
///**
// * Correct the padding in Firefox.
// */
//
//fieldset {
//  padding: 0.35em 0.75em 0.625em;
//}
//
///**
// * 1. Correct the text wrapping in Edge and IE.
// * 2. Correct the color inheritance from `fieldset` elements in IE.
// * 3. Remove the padding so developers are not caught out when they zero out
// *    `fieldset` elements in all browsers.
// */
//
//legend {
//  box-sizing: border-box; /* 1 */
//  color: inherit; /* 2 */
//  display: table; /* 1 */
//  max-width: 100%; /* 1 */
//  padding: 0; /* 3 */
//  white-space: normal; /* 1 */
//}
//
///**
// * 1. Add the correct display in IE 9-.
// * 2. Add the correct vertical alignment in Chrome, Firefox, and Opera.
// */
//
//progress {
//  display: inline-block; /* 1 */
//  vertical-align: baseline; /* 2 */
//}
//
///**
// * Remove the default vertical scrollbar in IE.
// */
//
//textarea {
//  overflow: auto;
//}
//
///**
// * 1. Add the correct box sizing in IE 10-.
// * 2. Remove the padding in IE 10-.
// */
//
//[type="checkbox"],
//[type="radio"] {
//  box-sizing: border-box; /* 1 */
//  padding: 0; /* 2 */
//}
//
///**
// * Correct the cursor style of increment and decrement buttons in Chrome.
// */
//
//[type="number"]::-webkit-inner-spin-button,
//[type="number"]::-webkit-outer-spin-button {
//  height: auto;
//}
//
///**
// * 1. Correct the odd appearance in Chrome and Safari.
// * 2. Correct the outline style in Safari.
// */
//
//[type="search"] {
//  -webkit-appearance: textfield; /* 1 */
//  outline-offset: -2px; /* 2 */
//}
//
///**
// * Remove the inner padding and cancel buttons in Chrome and Safari on macOS.
// */
//
//[type="search"]::-webkit-search-cancel-button,
//[type="search"]::-webkit-search-decoration {
//  -webkit-appearance: none;
//}
//
///**
// * 1. Correct the inability to style clickable types in iOS and Safari.
// * 2. Change font properties to `inherit` in Safari.
// */
//
//::-webkit-file-upload-button {
//  -webkit-appearance: button; /* 1 */
//  font: inherit; /* 2 */
//}
//
///* Interactive
//   ========================================================================== */
//
///*
// * Add the correct display in IE 9-.
// * 1. Add the correct display in Edge, IE, and Firefox.
// */
//
//details, /* 1 */
//menu {
//  display: block;
//}
//
///*
// * Add the correct display in all browsers.
// */
//
//summary {
//  display: list-item;
//}
//
///* Scripting
//   ========================================================================== */
//
///**
// * Add the correct display in IE 9-.
// */
//
//canvas {
//  display: inline-block;
//}
//
///**
// * Add the correct display in IE.
// */
//
//template {
//  display: none;
//}
//
///* Hidden
//   ========================================================================== */
//
///**
// * Add the correct display in IE 10-.
// */
//
//[hidden] {
//  display: none;
//}

public let renderedNormalizeCss = """
/*! normalize.css v7.0.0 | MIT License | github.com/necolas/normalize.css */html{line-height:1.15;-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}body{margin:0}article,aside,footer,header,nav,section{display:block}h1{font-size:2em;margin:.67em 0}figcaption,figure,main{display:block}figure{margin:1em 40px}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:transparent;-webkit-text-decoration-skip:objects}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:inherit}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}dfn{font-style:italic}mark{background-color:#ff0;color:#000}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}audio,video{display:inline-block}audio:not([controls]){display:none;height:0}img{border-style:none}svg:not(:root){overflow:hidden}button,input,optgroup,select,textarea{font-family:sans-serif;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}[type=reset],[type=submit],button,html [type=button]{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{display:inline-block;vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-cancel-button,[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details,menu{display:block}summary{display:list-item}canvas{display:inline-block}template{display:none}[hidden]{display:none}/*# sourceMappingURL=normalize.min.css.map */
"""
