#let canvas(content) = context {
  if target() == "html" {
    html.div(role: "img", html.frame({
      set text(
        font: (
          (name: "Maple Mono NF", covers: "latin-in-cjk"),
          "LXGW WenKai Mono",
        ),
        fallback: true,
      )
      content
    }))
  } else {
    content
  }
}
