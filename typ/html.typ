#let html-base(content) = {
  show math.equation.where(block: false): it => {
    html.span(role: "math",html.frame(it))
  }
  show math.equation.where(block: true): it => {
    html.div(role: "math", html.frame(it))
  }
  show raw.where(block: true): it => {
    html.details(class: "code-wrapper", open: true, {
      html.summary(it.lang)
      html.pre(class: "code-block", it.text)
    })
  }

  show h: it => {
    let amount = repr(it.amount)
    if amount.slice(-2) == "em" {
      let length =  float(amount.slice(0,-2))
      if length > 0 {
        text(" ") * int(length * 2)
      }
    }
  }

  content
}
