#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge


#show: post.with(
  title: [How to Create a Blog with `Typst`],
  subtitle: [Module Description],
  authors: ("Bendancom"),
  description: [Detailed explanation of each module in the blog and its functions],
  date: datetime(year: 2026,month: 4,day: 23),
  lastModDate: none,
  category: "Technology",
  tags: ("Typst","Blog","Modules"),
  order: 1,
  image: none,
  lang: "en",
)

#show: abbr

= Overview

Using `Python` as the scripting language for building, without any additional installed packages.
`build.py` is responsible for compiling `Typst` source files into static `HTML` pages, generating corresponding resource files, feeds, and sitemaps. This document will parse the key modules one by one.

== Module structure

`build.py` mainly contains the following modules:

- Configuration loading, constant definitions, utility functions (`URL` mapping, `CSS`/`JS` link generation)
- `Typst` processing
  - Metadata
  - Raw `HTML` content
  - Post-processed `HTML` content
- `SEO`
  - `OpenGraph` generation
  - Sitemap generation
  - `Atom` feed generation
- Page component generation
  - Header
  - Navigation bar
  - Metadata display bar
  - Sidebar
  - Content
  - Copyright information
- Page generation
  - Home page
  - Articles
  - Archive
  - About
- Build

The core of the entire project lies in `Typst` compilation and its `HTML` adaptation. All other modules are auxiliary around it.

= Configuration loading, constant definitions and utility functions

Defines the project's base directories and file paths, while loading `config.toml` and `lang.toml` configuration files for use by subsequent functions.

- `urljoin`: Handles relative path mapping.
- `generateStyle`: Generates `<link rel="stylesheet">` tags, automatically calling `urljoin` to process paths.
- `generateJS`: Generates `<script>` tags, supporting both module and non-module forms.

= `Typst` processing

#figure(
  canvas({
    set text(size: 9pt)
    diagram(
      node-stroke: 1pt,
      node((0,0), [`Typst` file], corner-radius: 0.5em),

      edge((0,0), (0,1), "-|>"),
      node((0,1), [Metadata], corner-radius: 0.5em),

      edge((0,1), (-1,1), (-1,0), "-|>"),
      node((-1,0), [Sitemap], corner-radius: 0.5em),

      edge((0,1), (1,1), "-|>"),
      node((1,1), [#grid(columns: 1, [Title],[Subtitle],[Description], row-gutter: 0.5em)], corner-radius: 0.5em),

      edge((1,1), (2,1), "-|>"),
      edge((0,0), (2,0), (2,1),"-|>"),
      node((2,1), [Raw `HTML` content], corner-radius: 0.5em),
      edge((2,1), (2,2), "-|>"),
      node((2,2), [`HTML` content], corner-radius: 0.5em),

      edge((0,1), (0,2), (1,2), "-|>"),
      node((1,2), [Header], corner-radius: 0.5em),
      edge((0,1), (0,3), (1,3), "-|>"),
      node((1,3), [Sidebar], corner-radius: 0.5em),
      edge((0,1), (0,4), (1,4), "-|>"),
      node((1,4), [Metadata display bar], corner-radius: 0.5em),

      edge((2,2), (2,3), "-|>"),
      edge((1,2), (1.5,2), (1.5,3), (2,3), "-|>"),
      edge((1,3), (2,3), "-|>"),
      edge((1,4), (1.5,4), (1.5,3), (2,3), "-|>"),
      node((2,3), [Article], corner-radius: 0.5em),
      edge((2.5,3), (2,3), "-|>"),

      edge((2,2), (3,2), (3,5), (2,5), (2,4), "-|>"),
      edge((0,1), (-1,1), (-1,5), (2,5), (2,4), "-|>"),
      node((2,4), [`Atom` feed], corner-radius: 0.5em),
    )
  }),
  caption: [Brief flowchart of `Typst` file processing],
) <img1>


The purpose of `Typst` processing is to obtain the article metadata as shown in @img1 and to compile and process the article into `HTML` content. All subsequent parts are for ergonomics and promotion.

The involved functions:

- `compileTypstStr(content: str) -> str`
- `getMetadata(file: Path) -> dict`
- `compileTypst(file: Path) -> str`
- `sortMetadate(metadates: list) -> list`

= SEO

== `OpenGraph` generation

This should actually be placed in the header, but it is listed separately to clarify the module structure.

Function: `generateOpenGraph(metadata: dict) -> str`

Generates `<title>`, `<meta>` and other `SEO` tags based on metadata, supporting the Open Graph protocol.

== `Atom` feed

Function: `generateFeed(lang: str, metadatas: list) -> str`

Generates an `Atom` format feed file (`feed.atom`).

Adds the feed `URL` link in the header, facilitating discovery by feed readers.

== Sitemap

Function: `generateSiteMap(lang, metadatas)`

Generates an `XML` format sitemap (`sitemap.xml`).

After submitting the sitemap `URL` address to major search engines, they will automatically add web page indexes, allowing others to discover and visit.

= Page component generation

== Header

Function: `generateHead(metadata, js, styles, haveLicense, haveSEO, prevLink, nextLink) -> str`

Assembles the `<head>` section of the page, containing `SEO` tags, stylesheets, scripts, pagination links, etc.

== Navigation bar

Function: `generateNavbar(metadata, selector, finder, languageSwitch, languageList) -> dict`

Generates navigation bar `HTML`, deciding whether to include components such as selector, search box, language switching based on parameters.

== Sidebar

Function: `generateSideBar(metadata, alltags, allcategories) -> str`

Generates the sidebar, displaying widgets such as categories, tags, personal profile, etc.

== Metadata display bar

Function: `generateMetadata(metadata, TitleLink) -> str`

Generates the article metadata area, containing title, author, date, category, tags, etc., with the option to set the title as a link.

= Page generation

== Home page

Function: `generateHome(lang, metadatas, alltags, allcategories, languageList)`

Generates the home page, displaying the latest article cards.

== Articles

Function: `generatePosts(metadatas, alltags, allcategories)`

Generates all article pages, supporting pagination navigation for series articles (`series`).

== Archive

Function: `generateArchive(lang, metadatas, alltags, allcategories, languageList)`

Generates the archive page, listing all content by series or individual articles.

== About

Function: `generateAbout(metadata, aboutContent, alltags, allcategories, languageList)`

Generates the about page.

= Main build process

The `build()` function is the entry point of the script, executing the following steps sequentially:

+ Traverse the `content` directory, finding all `.typ` files.
+ Extract metadata
+ Count tags and categories.
+ Copy static resources, comparing the last modification date of the target in the build directory with the source file, updating or building the target if it does not exist.
+ Generate multilingual home pages, about pages, archive pages, article pages, feeds, and sitemaps.
+ Output build completion prompt.
