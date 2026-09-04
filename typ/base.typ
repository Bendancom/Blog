#import "@preview/numbly:0.1.0": numbly

#let hue = 250deg

#let base(content) = {
  // code block
  show raw.where(block: true): it => {
    block(
      fill: oklch(12%, 1.5%, hue),
      radius: (top: 1em),
      it.lang,
    )
    block(
      fill: oklch(40%, 8%, hue),
      inset: 1em,
      radius: (bottom: 1em),
      it,
    )
  }

  // figure
  show figure.where(kind: table): set figure.caption(position: top)

  // heading
  set heading(numbering: numbly(
    "{1}",
    "{1}.{2}",
    "{1}.{2}.{3}",
    "{1}.{2}.{3}.{4}",
  ))

  // math
  set math.mat(delim: "[")

  // bibliography
  set bibliography(full: false, style: "gb-7714-2015-numeric")

  content
}
