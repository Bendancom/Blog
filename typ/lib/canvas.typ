#let canvas(content) = context {
  if target() == "html" {
    html.div(role: "img", html.frame(content))
  } else {
    content
  }
}
