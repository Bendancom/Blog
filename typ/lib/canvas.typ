#import "@preview/cetz:0.4.2"

#let canvas(..args) = context {
  if target() == "html" {
    html.div(role: "img", html.frame(cetz.canvas(..args)))
  } else {
    cetz.canvas(..args)
  }
}
