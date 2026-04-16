#let preview(content) = context {
  if target() == "html" {
    html.pre(content)
  }
  else {
    content
  }
}
