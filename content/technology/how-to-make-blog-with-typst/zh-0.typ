#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/cetz:0.4.2"
#import "@preview/physica:0.9.8": *

#show: post.with(
  title: [如何使用`Typst`创建博客],
  subtitle: [前言],
  authors: ("岑白"),
  description: [为什么要选择`Typst`作为博客写作的标记语言，为什么要写这一个系列],
  date: datetime(year: 2026,month: 4,day: 12),
  lastModDate: none,
  category: "技术",
  tags: ("Typst","博客"),
  order: 0,
  image: none,
  lang: "zh",
)

#show: abbr

= 为什么用`Typst`来写博客

== 技术型博客

=== 公式

笔者的需求就是要写一些技术性的文章，其势必会大量用到各类数学公式、符号，`Markdown`可以写，但太眼花缭乱。`Markdown`的数学公式是由`LaTex`语法渲染得来的，而`LaTex`语法本身可以称为宏。那问题来了，`Markdown` 为了渲染一致性必定不会使用指定的扩展包之外的任何宏。这导致公式中充斥着大量的重复。

举个例子，按标准规定的微分符号的写法：

$ dif y =  4 dif x $

这是`Typst`实现：

```typ
dif y = 4 dif x
```

这是`LaTex`实现：

```tex
\mathrm{d}\, y = 4 \mathrm{d}\, x
```

本来若是全面的`LaTex`可以添加一个宏来大幅简化，但`Markdown`不全面，其`LaTex`宏定义功能的支持程度全指望本地渲染环境。

还有就是`LaTex`的公式一眼看过去太多反斜杠、大括号了，其可读性太差。若是思路连续公式一遍过那还好，但要是改几个变量，那可太难找了。

=== 绘图

`Markdown`就没打算绘图，能绘图的`Obsidian`是单独绘图然后嵌入到`Markdown`中的。

=== 扩展包

参考文献的引用，其他方便写作的包的调用，这些`Markdown`都没有。

== 样式

- `Markdown`的样式都是由本地渲染器来决定的，写作时根本不需要考虑。但若是要自定义来显示就困难了。
- `Typst`的`HTML`支持仍然缺少样式。

所以最终得要看`CSS`来自定义样式了

== 模块化

对于数据、代码的模块化，将之拆分更好来写作。

= 为什么要写这一个系列

- 记录实现过程，整理思路
- 帮助需要的人

= Typst 展示 <performence>

== 基本

=== 文字

在遥远的北方，有一座被群山环绕的小城。每逢冬季，大雪便会覆盖整片山谷，将屋顶和街道染成纯净的白色。清晨时分，炊烟从低矮的烟囱里袅袅升起，与雾气交织在一起，仿佛为这座安静的小城披上了一层薄纱。老人们习惯在炉火旁煮一壶热茶，听着窗外雪花簌簌落下的声音，慢慢度过漫长的午后。偶尔有孩子在巷子里堆雪人、打雪仗，清脆的笑声打破了冬日的沉寂。这里没有大城市的喧嚣与匆忙，时间仿佛流淌得格外缓慢，每一刻都值得细细品味。

注：@AI:s 生成

=== 图片

#figure(
  image("/assets/image/technology/how-to-make-blog-with-typst/test.png"),
  caption: [测试图片],
)

=== 表格

#figure(
  table(
    columns: 3,
    table.header([1],[2],[3]),
    [222],[111],[333],
    [444],[555],[666]
  ),
  caption: [测试表格]
)

=== 代码

```zig
const Point = struct {
    x: f32,
    y: f32,
    z: f32
};
```

=== 链接

#link(<performence>)[跳转到 Typst 展示]

#link("http://github.com/bendancom")[Bendancom的Github主页]

#link("/assets/image/avatar.png")[个人头像]

=== 公式

行内公式 $ee = dv(y,x)$

行间公式：
$
  f(x) = x_0 + x_1 ii + x_2 jj + x_3 kk \ 
  g(y) = y_0 + y_1 ii + y_2 jj + y_3 kk
$

=== 文献

#{
  [文献引用@bendancom-preface]
  show heading.where(level: 1): it => {}
  bibliography("refs.yml")
}

== 扩展包

相对于不引用包的`Typst`

对于数学、物理类的包几乎全适配，只要其走的是`Typst`的公式渲染

- #link("https://typst.app/universe/package/cetz/")[cetz]
- #link("https://typst.app/universe/package/abbr/")[abbr]

=== 绘图

#canvas({
  import cetz.draw: *
  circle((0,0))
  line((0,0),(2,1))
})

=== 缩写词表

#{
  show heading.where(level: 1): it => {}
  abbr-list()
}

@PDE

@PDE:s
