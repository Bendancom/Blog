#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/cetz:0.4.2"
#import "@preview/physica:0.9.8": *

#show: post.with(
  title: [How to Create a Blog with `Typst`],
  subtitle: [Preface],
  authors: ("Bendancom"),
  description: [Why choose `Typst` as the markup language for blog writing, and why write this series],
  date: datetime(year: 2026,month: 4,day: 12),
  lastModDate: none,
  category: "Technology",
  tags: ("Typst","Blog"),
  order: 0,
  image: none,
  lang: "en",
)

#show: abbr

= Why use `Typst` to write a blog

== Technical blog

=== Formulas

My requirement is to write technical articles, which will inevitably involve extensive use of various mathematical formulas and symbols. `Markdown` can handle them, but it's too cluttered. The mathematical formulas in `Markdown` are rendered using `LaTeX` syntax, and `LaTeX` syntax itself can be considered macros. The problem is that `Markdown`, for rendering consistency, definitely does not use any macros outside the specified extension packages. This leads to a lot of repetition in formulas.

For example, the standard way to write the differential symbol:

$ dif y =  4 dif x $

This is the `Typst` implementation:

```typ
dif y = 4 dif x
```

This is the `LaTeX` implementation:

```tex
\mathrm{d}\, y = 4 \mathrm{d}\, x
```

If using full `LaTeX`, one could add a macro to greatly simplify it, but `Markdown` is not comprehensive; its support for `LaTeX` macro definition depends entirely on the local rendering environment.

Moreover, `LaTeX` formulas contain too many backslashes and braces at first glance, which makes them poorly readable. If the thought process is continuous and the formula is written in one go, it's fine, but if you need to modify a few variables, it becomes too difficult to locate them.

=== Drawing

`Markdown` never intended to draw; `Obsidian`, which can draw, draws separately and then embeds it into `Markdown`.

=== Extension packages

References, citations, and calls to other convenient writing packages—none of these are available in `Markdown`.

== Styling

- `Markdown`'s styling is entirely determined by the local renderer, so there's no need to consider it while writing. However, customizing the display is difficult.
- `Typst`'s `HTML` support still lacks styling.

Thus, ultimately one must rely on `CSS` for custom styling.

== Modularization

For modularization of data and code, splitting them facilitates writing.

= Why write this series

- Record the implementation process, organize thoughts
- Help those in need

= Typst demonstration <performence>

== Basics

=== Text

In the distant north, there is a small town surrounded by mountains. Every winter, heavy snow blankets the entire valley, turning rooftops and streets a pristine white. In the early morning, smoke rises gently from low chimneys, intertwining with the mist, as if draping a thin veil over this quiet town. The elderly are accustomed to brewing a pot of hot tea by the fireplace, listening to the sound of snowflakes falling softly outside the window, slowly passing the long afternoons. Occasionally, children build snowmen and have snowball fights in the alleyways, their crisp laughter breaking the winter stillness. Here, there is no hustle and bustle of big cities; time seems to flow exceptionally slowly, every moment worth savoring.

Note: @AI:s generated.

=== Image

#figure(
  image("/assets/image/technology/how-to-make-blog-with-typst/test.png"),
  caption: [Test image],
)

=== Table

#figure(
  table(
    columns: 3,
    table.header([1],[2],[3]),
    [222],[111],[333],
    [444],[555],[666]
  ),
  caption: [Test table]
)

=== Code

```zig
const Point = struct {
    x: f32,
    y: f32,
    z: f32
};
```

=== Links

#link(<performence>)[Jump to Typst demonstration]

#link("http://github.com/bendancom")[Bendancom's Github homepage]

#link("/assets/image/avatar.png")[Personal avatar]

=== Formulas

Inline formula $ee = dv(y,x)$

Display formula:
$
  f(x) = x_0 + x_1 ii + x_2 jj + x_3 kk \ 
  g(y) = y_0 + y_1 ii + y_2 jj + y_3 kk
$

=== References

#{
  [Reference citation@bendancom-preface]
  show heading.where(level: 1): it => {}
  bibliography("refs.yml")
}

== Extension packages

Compared to `Typst` without package references

For mathematics and physics packages, almost all are compatible as long as they utilize `Typst`'s formula rendering.

- #link("https://typst.app/universe/package/cetz/")[cetz]
- #link("https://typst.app/universe/package/abbr/")[abbr]

=== Drawing

#canvas({
  import cetz.draw: *
  circle((0,0))
  line((0,0),(2,1))
})

=== Abbreviation list

#{
  show heading.where(level: 1): it => {}
  abbr-list()
}

@PDE

@PDE:s
