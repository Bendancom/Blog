#import "@preview/abbr:0.3.0" as abbrevia

#let lang = toml("/lang.toml")

#let abbr(content) = context {
  show: abbrevia.show-rule

  let abbr-lang = lang.abbr.at(text.lang)
  let unpack(item) = {
    (item, abbr-lang.at(item))
  }

  abbrevia.make(
    unpack("PDE")
  )

  content
}

#let abbr-list() = context {
  abbrevia.list(columns: 1,title: lang.config.at(text.lang).abbrList)
}
