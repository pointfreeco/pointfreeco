public let renderedNormalizeCss: StaticString = """
  /*! normalize.css v8.0.0 | MIT License | github.com/necolas/normalize.css */html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details{display:block}summary{display:list-item}template{display:none}[hidden]{display:none}
  """

public struct BaseStyles: HTML {
  public init() {}

  public var body: some HTML {
    style { "\(renderedNormalizeCss)" }
    style {
      """
      html {
        font-family: ui-sans-serif, -apple-system, Helvetica Neue, Helvetica, Arial, sans-serif;
        line-height: 1.5;
        -webkit-box-sizing: border-box;
        -moz-box-sizing: border-box;
        -ms-box-sizing: border-box;
        -o-box-sizing: border-box;
        box-sizing: border-box;
      }
      code, pre, tt, kbd, samp {
        font-family: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, Monaco, Consolas, monospace;
      }
      body {
        -webkit-box-sizing: border-box;
        -moz-box-sizing: border-box;
        -ms-box-sizing: border-box;
        -o-box-sizing: border-box;
        box-sizing:border-box
      }
      *, * ::before, * ::after {
        -webkit-box-sizing: inherit;
        -moz-box-sizing: inherit;
        -ms-box-sizing: inherit;
        -o-box-sizing: inherit;
        box-sizing:inherit
      }
      body, html {
        background: #fff;
      }
      @media (prefers-color-scheme: dark) {
        body, html {
          background: #121212;
        }
      }
      .markdown *:link, .markdown *:visited { color: inherit; }
      .diagnostic * {
        font: inherit;
        line-height: 1.25 !important;
      }
      .diagnostic pre {
        background: inherit;
        margin: 0 1.125rem;
        padding: 0;
        text-wrap: auto;
      }
      @media only screen and (min-width: 832px) {
        html {
          font-size: 16px;
        }
      }
      @media only screen and (max-width: 831px) {
        html {
          font-size: 14px;
        }
      }
      @keyframes Pulse {
        from { opacity: 1; }
        50% { opacity: 0; }
        to { opacity: 1; }
      }
      """
    }
  }
}
