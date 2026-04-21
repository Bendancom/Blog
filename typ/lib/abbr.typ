#import "@preview/abbr:0.3.0" as abbrevia

#let lang = toml("/lang.toml")

#let abbr(content) = context {
  show: abbrevia.show-rule

  let abbr-lang = lang.abbr.at(text.lang)
  let abbrs = ()
  for (key,value) in abbr-lang.pairs() {
    abbrs.push((key, abbr-lang.at(key)))
  }

  abbrevia.make(
    ..abbrs
  )

  content
}

#let abbr-list() = context {
  abbrevia.list(columns: 1,title: lang.config.at(text.lang).abbrList)
}
