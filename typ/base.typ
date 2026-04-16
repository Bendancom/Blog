#import "@preview/t4t:0.4.3": get
#import "@preview/percencode:0.1.0": percent-decode
#import "@preview/numbly:0.1.0": numbly

#let hue = 250deg

#let base(content) = {
  show regex("(%\w\w)+"): it => percent-decode(get.text(it))
  show raw.where(block: true): it => {
    block(
      fill: oklch(12%,1.5%,hue),
      radius: (top: 1em),
      it.lang
    )
    block(
      fill: oklch(40%,8%,hue),
      inset: 1em,
      radius: (bottom: 1em),
      it
    )
  }

  show figure.where(kind: table): set figure.caption(position: top)

  set heading(numbering: numbly(
    "{1}",
    "{1}.{2}",
    "{1}.{2}.{3}",
    "{1}.{2}.{3}.{4}"
  ))

  set bibliography(full: false,style: "gb-7714-2015-numeric")

  content
}
