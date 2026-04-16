#import "html.typ": html-base
#import "base.typ": base

#let _title = title

//  title and description not support any packages,because the metadata function can't througt out the content within package
#let post(
  title: content,
  subtitle: content,
  authors: array,
  date: datetime,
  lastModDate: datetime,
  description: content,
  category: str,
  tags: array,
  order: int,
  image: str,
  lang: str,
  content
) = context {
  metadata((
    metadata: (
      title: title,
      subtitle: subtitle,
      authors: authors,
      date: ( if date != none {date.display("[year]-[month]-[day]")} else {none} ),
      lastModDate: ( if lastModDate != none { lastModDate.display("[year]-[month]-[day]") } else {none} ),
      description: description,
      category: category,
      tags: tags,
      order: order,
      image: image,
      lang: lang,
  )))

  set document(
    title: title,
    author: authors,
    date: date,
    description: description,
    keywords: tags,
  )
  set text(lang: lang)

  show: base

  if target() == "html" {
    show: html-base
    content
  } else {
    _title()
    content
  }
}
