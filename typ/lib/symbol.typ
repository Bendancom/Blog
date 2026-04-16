#import "@preview/symbolist:0.1.0": def-symbol, get-latin-symbols, get-greek-symbols

#let lang = toml("/lang.toml")

#let symbol(content) = context {
  let sym = lang.symbol.at(text.lang)
  def-symbol($F$,sym.Force,unit: "N")
  def-symbol($m$,sym.Mass,unit: "kg")
  content
}

#let symbol-list(columns) = context [
  #assert(type(columns) == int)
  #assert(columns == 2 or columns == 3)
  = #lang.config.at(text.lang).symbolList
  #{
    let latin-symbols = get-latin-symbols()
    table(
      columns: columns,

    )
  }
]
