#let _image = image

#let image(..args) = context {
  let src = args.pos().at(0)
  let params = args.named()

  if src.find(regex("^https?://\S+")) != none {
    if target() == "html" {
      html.img(src: src, ..params)
    }
  } else {
    if target() == "html" {
      if src.find("/assets") != none {
        html.img(src: src, ..params)
      } else {
        _image(..args)
      }
    } else {
      _image(..args)
    }
  }
}
