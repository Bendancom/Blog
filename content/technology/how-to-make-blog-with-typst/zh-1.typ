#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge


#show: post.with(
  title: [如何使用`Typst`创建博客],
  subtitle: [模块说明],
  authors: ("岑白Bd"),
  description: [详细解释博客中的各个模块及其功能],
  date: datetime(year: 2026,month: 4,day: 23),
  lastModDate: none,
  category: "技术",
  tags: ("Typst","博客","模块"),
  order: 1,
  image: none,
  lang: "zh",
)

#show: abbr

= 概述

使用 `Python`作为脚本语言来构建，不使用任何额外安装的包。
`build.py` 负责将 `Typst` 源文件编译为静态 `HTML` 页面，并生成相应的资源文件、订阅源和站点地图。本文件将逐一解析其中的关键模块。

== 模块结构

`build.py` 主要包含以下模块：

- 配置加载、常量定义、工具函数（`URL`映射、`CSS`/`JS`链接生成）
- `Typst`处理
  - 元数据
  - 原始`HTML`内容
  - 后处理`HTML`内容
- `SEO`
  - `OpenGraph` 生成
  - 站点地图生成
  - `Atom`订阅生成
- 页面组件生成
  - 标头
  - 导航栏
  - 元数据展示栏
  - 侧边栏
  - 内容
  - 版权信息
- 页面生成
  - 主页
  - 文章
  - 归档
  - 关于
- 构建

整个项目的核心在于`Typst`编译以及其下的`HTML`适配。其他所有模块都是围绕其进行辅助。

= 配置加载、常量定义与工具函数

定义了项目的基础目录和文件路径，同时加载 `config.toml` 和 `lang.toml` 配置文件，供后续函数使用。

- `urljoin`：处理相对路径的映射。
- `generateStyle`：生成 `<link rel="stylesheet">` 标签，自动调用 `urljoin` 处理路径。
- `generateJS`：生成 `<script>` 标签，支持模块与非模块两种形式。

= `Typst`处理

#figure(
  canvas({
    set text(size: 9pt)
    diagram(
      node-stroke: 1pt,
      node((0,0), [`Typst`文件], corner-radius: 0.5em),

      edge((0,0), (0,1), "-|>"),
      node((0,1), [元数据], corner-radius: 0.5em),

      edge((0,1), (-1,1), (-1,0), "-|>"),
      node((-1,0), [站点地图], corner-radius: 0.5em),

      edge((0,1), (1,1), "-|>"),
      node((1,1), [#grid(columns: 1, [标题],[副标题],[描述], row-gutter: 0.5em)], corner-radius: 0.5em),

      edge((1,1), (2,1), "-|>"),
      edge((0,0), (2,0), (2,1),"-|>"),
      node((2,1), [原始`HTML`内容], corner-radius: 0.5em),
      edge((2,1), (2,2), "-|>"),
      node((2,2), [`HTML`内容], corner-radius: 0.5em),

      edge((0,1), (0,2), (1,2), "-|>"),
      node((1,2), [标头], corner-radius: 0.5em),
      edge((0,1), (0,3), (1,3), "-|>"),
      node((1,3), [侧边栏], corner-radius: 0.5em),
      edge((0,1), (0,4), (1,4), "-|>"),
      node((1,4), [元数据展示栏], corner-radius: 0.5em),

      edge((2,2), (2,3), "-|>"),
      edge((1,2), (1.5,2), (1.5,3), (2,3), "-|>"),
      edge((1,3), (2,3), "-|>"),
      edge((1,4), (1.5,4), (1.5,3), (2,3), "-|>"),
      node((2,3), [文章], corner-radius: 0.5em),
      edge((2.5,3), (2,3), "-|>"),

      edge((2,2), (3,2), (3,5), (2,5), (2,4), "-|>"),
      edge((0,1), (-1,1), (-1,5), (2,5), (2,4), "-|>"),
      node((2,4), [`Atom` 订阅], corner-radius: 0.5em),
    )
  }),
  caption: [`Typst`文件处理的简要流程图],
) <img1>


`Typst`处理的目的是得到 @img1 中的文章元数据以及将文章编译并处理为`HTML`内容。所有之后的部分都是为了人机工效以及推广。

其涉及函数：

- `compileTypstStr(content: str) -> str`
- `getMetadata(file: Path) -> dict`
- `compileTypst(file: Path) -> str`
- `sortMetadate(metadates: list) -> list`

= SEO

== `OpenGraph` 生成

实际上这应该放在标头中，但将其独立列出以更明晰模块结构。

函数：`generateOpenGraph(metadata: dict) -> str`

根据元数据生成 `<title>`、`<meta>` 等 `SEO` 标签，支持 `Open Graph` 协议。

== `Atom` 订阅

函数：`generateFeed(lang: str, metadatas: list) -> str`

生成 `Atom` 格式的订阅源文件（`feed.atom`）。

在标头中添加订阅的`URL`链接，便于订阅软件查找。

== 站点地图

函数：`generateSiteMap(lang, metadatas)`

生成 `XML` 格式的站点地图（`sitemap.xml`）。

在各大搜索引擎提交站点地图的`URL`地址过后，搜索引擎将会自动去添加网页索引，让其他人可以发现并访问。

= 页面组件生成

== 标头

函数：`generateHead(metadata, js, styles, haveLicense, haveSEO, prevLink, nextLink) -> str`

组装页面的 `<head>` 部分，包含 `SEO` 标签、样式表、脚本、分页链接等。

== 导航栏

函数：`generateNavbar(metadata, selector, finder, languageSwitch, languageList) -> dict`

生成导航栏 `HTML`，根据参数决定是否包含选择器、搜索框、语言切换等组件。

== 侧边栏

函数：`generateSideBar(metadata, alltags, allcategories) -> str`

生成侧边栏，显示分类、标签、个人资料等小部件。

== 元数据展示栏

函数：`generateMetadata(metadata, TitleLink) -> str`

生成文章元数据区域，包含标题、作者、日期、分类、标签等，并可选择是否将标题设置为链接。

= 页面生成

== 主页

函数：`generateHome(lang, metadatas, alltags, allcategories, languageList)`

生成首页，展示最新的文章卡片。

== 文章

函数：`generatePosts(metadatas, alltags, allcategories)`

生成所有文章页面，支持系列文章（`series`）的分页导航。

== 归档

函数：`generateArchive(lang, metadatas, alltags, allcategories, languageList)`

生成归档页面，按系列或单篇文章列出所有内容。

== 关于

函数：`generateAbout(metadata, aboutContent, alltags, allcategories, languageList)`

生成关于页面。

= 主构建流程

`build()` 函数是脚本的入口点，依次执行以下步骤：

+ 遍历 `content` 目录，找到所有 `.typ` 文件。
+ 提取元数据
+ 统计标签和分类。
+ 复制静态资源，将构建目录下的目标的最后修改日期和源文件对比，更新或不存在就构建生成目标。
+ 生成多语言首页、关于页、归档页、文章页、订阅源和站点地图。
+ 输出构建完成提示。
