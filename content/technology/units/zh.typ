#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/unify:0.7.1": qty,num,unit
#import "@preview/physica:0.9.8": vb, va, dmat

#show: post.with(
  title: [单位库实现],
  subtitle: none,
  date: datetime(year: 2024,month: 8,day: 12),
  lastModDate: datetime(year: 2026,month: 4,day: 23),
  authors: "岑白Bd",
  description: [在现实世界中的物理规律都需要物理单位，相较于直接进行数字的计算，带有物理量的计算可进行量纲校验与单位换算。],
  tags: ("C++", "单位", "物理"),
  category: "技术",
  order: none,
  image: none,
  lang: "zh",
)

#show: abbr 

= 前置需求

- 线性代数（关于线性空间的变换）
- 道听途说的群论（一些可以说是常识性的运算群）
- 一些英语，有翻译也可（编程必须，不然容易看不懂变量）
- 简要的物理理解（涉及对称性）

#abbr-list()

= 数学理解

对于除了温度以外的所有量纲，其变换都是线性的。因而可以先普遍再特殊。

== 普遍

对于相同指数下的单位的变换，可认为是一个基于一种单位基底的线性空间到另一种单位基底的线性空间的线性变换。  
若对基进行变换，由于绝大部分物理单位间的变换都是线性变换，只有一个量纲下的物理量是仿射变换(说的就是你，温度)，先考虑绝大多数，那么可直接乘以一个变换矩阵，得到由新的基组成的单位。  
但该前提是所有量纲的指数都是 #num(1)，，或者说，在一个量纲中，不同的指数有不同的尺规。
如 $"in"$ 到 #unit("m") 的尺规是 #num(0.0254)，但 $"in"^2$ 到 #unit("m^2") 的尺规是 #num(6.4516) ($2.54^2$)。  
同时单位制词头的不同也带来了不同的尺规，#unit("m") 到 #unit("km") 的尺规为 #num(1000)，#unit("m^2") 到 #unit("km^2") 的尺规为 #num(1000000)

先看单量纲情况：
$
  x' &= m^p c^p x \
  vb(x)' &= dmat(delim: "[",fill: 0, (m_(1)c_(1))^(p), dots.down, (m_(n)c_(n))^(p)) vb(x) \
$

其中：
- $m$ 相对单位制词头
- $c$ 相对尺规
- $p$ 相对指数
- $x$ 原量纲
- $x'$ 现量纲

而对于这些变量的值的范围，有：

- $m in QQ^(+)$
- $c in RR^(+)$
- $p in QQ^(+)$

量纲指数的范围可以是有理数@addis-units

将其推广到多量纲。为简化表述，引入如下数学概念：

`Hadamard`积：逐元素积

$
  vb(a) dot.o vb(b) = vec(a_1 b_1, dots.v , a_n b_n)
$
`Hadamard`幂：逐元素幂

$
  vb(a)^(dot.o vb(b)) = vec(a_1^(b_1), dots.v, a_n^(b_n))
$

可得：

$
  vb(x)' = vb(M)^(dot.o vb(P)) dot.o vb(C)^(dot.o vb(P)) vb(x)
$

其中：
- $vb(M)$ 相对单位制词头的对角矩阵
- $vb(C)$ 相对尺规的对角矩阵
- $vb(P)$ 相对指数的对角矩阵

对于从原量纲到现量纲的变化量，即为变换矩阵的行列式：

$
  v = det(vb(M)^(dot.o vb(P)) dot.o vb(C)^(dot.o vb(P)))
$

其中：

- $v$ 变换量

一般用的是国际单位制，以千克、米、秒、开尔文等单位作为基本单位量。但有时为了方便表示以及约去某些常数如$pi$可以改换单位制，让公式更直观简洁。

以数学的语言表示就是变换向量的基底。

== 特殊

=== 赝矢量、赝标量、赝张量

赝矢量、赝标量、赝张量是物理学概念，其指在空间反演下改变手性的物理量，一般为力矩、角动量、角速度、角冲量等。

举个例子，空间反演如同镜像，镜像外为左手，镜像内为右手（以自身为参考系）。

以力矩为例，其赝标量为$abs(vb(F))abs(vb(r))sin theta$。然而数学中对于此并没有区分，因而若按数学概念那么力矩的量纲与能量相同，都为$M^(1)L^(2)T^(-2)$。

所以为了区分，需要单独将宇称独立出来作为一个量纲，其运算规则遵循异或群。

这导致另一个问题，对于纯数学的计算库，必须修改运算方式，将叉乘等会产生矢量、标量宇称性质变换的运算修改，为其额外添加一个宇称量纲以标注手性，即不能利用原有的泛函数学库。或者使用列维-奇维塔张量并为其添加宇称来表示叉乘等运算。

=== 温度

在温度量纲指数为#num(1)时，温度单位的变换为不过原点的一次函数。

- 在温度仅表示温差这一含义时，可忽略温差，只看温标。
- 在其余情况如只有温度这一量纲时，需同时看温标与温差。

#figure(
  table(
    columns: (auto, auto, auto),
    table.header[温度量纲][符号][转换为开尔文的函数],
    [开尔文], [#unit("K")], [$K = T_K$],
    [摄氏度], [#unit("celsius")], [$K = T_(degree upright(C)) + 273.15$],
    [华氏度], [$degree upright(F)$], [$K = (T_(degree upright(F)) + 459.67) times 5 / 9$],
    [兰金度], [$degree upright(R)$], [$K = T_(degree upright(R)) times 5 / 9$],
    [列氏度], [$degree upright(R e)$], [$K = T_(degree upright(R é)) times 5 / 4 + 273.15$],
    [牛顿温标], [$degree upright(N)$], [$K = T_(degree upright(N)) times 100 / 33 + 273.15$],
    [勒氏温标（罗氏）], [$degree upright(R ø)$], [$K = T_(degree upright(R ø)) times 40 / 21 + 273.15$],
    [德利尔温标], [$degree upright(D e)$], [$K = 373.15 - T_(degree upright(D e)) times 2 / 3$],
  ),
  caption: [各类温度量纲]
)

对此只有唯一方法：

单列一次量纲的温度变换，对于负指数量纲的温度变换可以忽略温差，其余只能在温差相同的情况下进行线性变换。

因为有黑体辐射这一4次温度量纲。

= 实现

推荐使用的编程语言支持：

- 编译期常量
- @SIMD:s
- 泛型

== 思路

单位库应包含如下内容

- 量纲
- 量（数字、矩阵、张量）

因而难点在于量纲，单位库的一切都是围绕量纲的，量只不过是附带的内容(虽然在计算中这才是主要的)。

=== 量纲

量纲种类是复杂的，依据实际情况而变化的，比如计算机图形学中会涉及到像素这一单位，这单位不能归到长度中，只能单列，参考@PPI:s。

在这里本人是将单位制词头与单位拆分，这样便于扩展，不用再实现同一单位的不同单位制词头。

- 量纲类型
  - 单位制词头
  - 尺规
- 指数

==== 单位制词头

单位制词头的存储方式也可以有所分类：

- 存储指数。优点省内存，精度高；缺点浪费算力。
- 存储差值。优点省算力；缺点内存占用大。

自行根据需求选择，也可以一起实现，通过编译参数来分别编译。

==== 尺规

尺规变换即线性变换中一个基底到另一个基底的变换

有两种方式：

- 绝对基底：所有变换都以某一单位来换算。优点是减少内存消耗；缺点是每次量纲变换都要对每个量纲进行一次运算，在大规模计算中浪费算力。
- 相对基底：所有单位到另一单位的换算都有直接的换算量。优点是省算力；缺点是内存占用大。

注意在实现中绝对基底是相对基底的真子集，所以绝对基底是无法绕过的。

两种方法有各自的好，完全可以一起用，通过编译参数进行区分。

=== 并行

并行优化一般是将大元素拆分为块进行并行计算，再将块内优化为多个向量化计算。

==== @SIMD:s

该优化完全看是用什么编程语言，用什么数据类型。首先编程语言要支持#[@SIMD:s]优化，其次要看数据类型，是支持向量化的数据类型还是说用户自定义的高精度数据类型。

现假设数据类型全为`FP64`，可优化的有以下几个方面：

- `Hadamard`幂：逐元素幂
  - 快速幂
- `Hadamard`积：逐元素积

==== @MIMD:s

该优化可以说是最普适的了，但不适合用在单一的两个数据间的计算，不然并行的开销大于并行的收益。

只适合大量的物理量计算和量纲转换。

== 代码

=== 量纲

==== 单位制词头

=== 幂函数

在cpp23中标准库仍有大部分未实现编译期常量的数学函数，其中就有`pow`，且所有数学函数都未实现泛型，因而要自己实现。
如下是简易的实现，便于演示没用快速幂算法。

```cpp
template<rational T>
constexpr T pow(rational auto x,integral auto p){
    if (p > 0){
        T temp = 1;
        for (size_t i=0;i<p;i++)
            temp = temp * x;
        return temp;
    }
    else if (p == 0){
        if (x != 0)
            return 1;
        else
            throw std::exception();
    }
    else {
        T temp = 1;
        for (size_t i=0;i<-p;i++)
            temp = temp / x;
        return temp;
    }
}
```

== 基类（量纲单位）

基类是一切扩展性的根源，要保留有最高的扩展性，因而使用模板进行定义：

=== 基类数据

其中应至少含有

- 尺规(`magnitude`)，要求范围为有理数$QQ$
- 指数(`power`)，要求范围为整数$ZZ$
- 简名(`short_name`)，要求为字符串
- 量纲简名(`dimension_short_name`)，要求为字符串

注：实际在物理中是真有指数为有理数的量纲操作的，但这样不好计算，详情参照 #link("https://wuli.wiki/online/Units.html")[小时百科-物理量和单位转换-例3]


如下为基类中数据的定义：

```cpp
template<rational magnitude_t,integral power_t>
struct basic_dimension{
    magnitude_t magnitude;
    power_t power;
    std::string_view short_name;
    std::string_view dimension_short_name;
};
```

其中`std::string_view`还可被优化为`const char* const`但除非是超大量的单位存储，否则这优化是没啥必要的（因为不如`std::string_view`类方便，在理解意义上的）

从基类中我们定义最通用的内存空间最小类：

```cpp
using dimension = basic_dimension<std::float,std::int8_t>;
```

=== 基类函数

在基类中应有完全比较函数即`operator==()`函数，比较全部四个数据；
也应应有类型比较函数`type_equal`，比较幂指数与唯一单位名；
还应有模板转换函数，为特殊超大单位提供无损转换

```cpp
template<rational magnitude_t,integral power_t>
struct basic_dimension{
    constexpr operator==(...) const;
    constexpr type_equal(...) const;
    static constexpr basic_dimension<...> convert(...) const;
};
```
要达成以上条件，其中的约束为：

- 为基类的任意派生
- 二者有可隐式转换的类型

```cpp
template<template<rational R,integral I> typename dimension_t,rational R,integral I>
requires requires {
    requires std::derived_from<dimension_t<R,I>,basic_dimension<R,I>>; 
    requires std::common_with<magnitude_t,R>;
    requires std::common_with<power_t,I>;
}
constexpr bool operator==(const dimension_t<R,I>& dimen) const {
    ...
}
```

== 单位制词头结构

其中有两种数据类型，这导致该结构更像是对基类（量纲单位）的包装

- 单位制词头
- 基类（量纲单位）

```cpp
template<rational magnitude_t,integral power_t>
struct basic_MP_dimension {
    MP metric_prefix;
    basic_dimension<magnitude_t, power_t> dimen;
};
```

=== 单位制词头

两种方式

- 采用对数表示，运用`char`数据类型存储
  - 优：空间换时间（但不至于这么省，又不是极限单片机），可能大概也许比较易懂
  - 劣：浪费计算时间
- 枚举类型 + 固定数组存储
  - 优：时间换空间
  - 劣：每多一个词头多占用`4`字节（默认`float = float32_t`，占用 32`bit`= 4`byte`）

选用第二种方法——枚举类型 + 固定数组存储。
采用`std::array`，会多8字节。
```cpp
enum class MP : char{
    Q,
    R,
    Y,
    Z,
    E,
    P,
    T,
    G,
    M,
    k,
    h,
    da,
    null,
    d,
    c,
    m,
    μ,
    n,
    p,
    f,
    a,
    z,
    y,
    r,
    q,
};

auto MP_array = std::to_array<float>({
    1e30,
    1e27,
    1e24,
    1e21,
    1e18,
    1e15,
    1e12,
    1e9,
    1e6,
    1e3,
    1e2,
    1e1,
    1,
    1e-1,
    1e-2,
    1e-3,
    1e-6,
    1e-9,
    1e-12,
    1e-15,
    1e-18,
    1e-21,
    1e-24,
    1e-27,
    1e-30
});
```
=== 结构函数

与基类（量纲单位）类似

```cpp
template<rational magnitude_t,integral power_t>
struct basic_MP_dimension {
    constexpr bool operator==(...) const;
    constexpr bool type_equal(...) const;
    static constexpr basic_dimension<...> convert(...) const;
};
```

约束略有不同，只需确保泛型模板参数之间可以隐式转换即可：
```cpp
template<rational R,integral I>
requires requires {
    requires std::common_with<magnitude_t,R>;
    requires std::common_with<power_t,I>;
}
constexpr bool operator==(const basic_MP_dimension<R,I>& MP_dimen) const {
    ...
}
```

== 单位类

前面的可以说是都是基础，接下来到了重点：单位类

```cpp
template<rational value_t,rational magnitude_t,integral power_t>
class basic_unit;
```

=== 类型别名

使用的类型别名

- `V`，一种类型，可转换为`value_t`，其约束为`std::convertible_to<V,value_t>`
- `M`，一种类型，可转换为`magnitude_t`，其约束为`std::convertible_to<M,magnitude_t>`
- `P`，一种类型，可转换为`power_t`，其约束为`std::convertible_to<P,power_t>`

以下省略`V`，`M`，`P`类型的约束

```cpp
using dimension_t = basic_MP_dimension<magnitude_t, power_t>;
using MP_Less_t = MP_dimension_less<magnitude_t, power_t>;
```

其中 `MP_dimension_less` 为：
```cpp
template<rational M,integral P>
struct MP_dimension_less {
    constexpr bool operator()(const basic_MP_dimension<M, P>& ldimen,const basic_MP_dimension<M, P>& rdimen) const {
        return ldimen.dimen.dimension_name < rdimen.dimen.dimension_name;
    }
};
```

=== 数据类型

- `value`，类型为`value_t`
- `dimens`，类型为`std::set<dimension_t,MP_Less_t>`

=== 模板类型转换

要注意因为是任意匹配类型，要进行模板类型转换才能插入
使用 `basic_MP_dimension::convert`

=== 初始化

- 空初始化
- 拷贝初始化
- 值初始化
- 值与单个单位类型初始化
- 值与复数单位类型初始化

```cpp
constexpr basic_unit() {}
constexpr basic_unit(const basic_unit<V, M, P>& unit);
constexpr basic_unit(const value_t& value);
constexpr basic_unit(const value_t& value,const basic_MP_dimension<M, P>& dimen);
template<std::ranges::input_range Rng>
constexpr basic_unit(const value_t& value, Rng&& range);
```

===== 初始化约束

因为对容器里存储类型的判断无法直接泛型，所以只能由同名变量来判断了。

```cpp
template<std::ranges::input_range Rng>
requires requires {
    requires std::same_as<
        decltype(
            std::ranges::range_value_t<Rng>::metric_prefix
        ),
        MP
    >;
    requires std::convertible_to<
        decltype(
            std::ranges::range_value_t<Rng>::dimen.magnitude
        ),
        magnitude_t
    >;
    requires std::convertible_to<
        decltype(
            std::ranges::range_value_t<Rng>::dimen.power
        ),
        power_t
    >;
    requires std::same_as<
        decltype(
            std::ranges::range_value_t<Rng>::dimen.short_name
        ),
        std::string_view
    >;
    requires std::same_as<
        decltype(
            std::ranges::range_value_t<Rng>::dimen.dimension_name
        ),
        std::string_view
    >;
}
constexpr basic_unit(const value_t& value, Rng&& range);
```

=== 尺度计算

```cpp
value_t MagnitudeCalculateFrom(const basic_unit<V, M, P>& u) const {
    value_t all_magnitude = 1;
    for(auto i : dimens) {
        value_t magni = 1;
        auto dimen = basic_MP_dimension<M, P>::convert(i);
        if (auto iter = u.getDimensions().find(dimen); iter != u.getDimensions().end()){
            magni *= pow<value_t>(iter->dimen.magnitude / i.dimen.magnitude, iter->dimen.power);
            magni *= pow<value_t>(MP_array[(char)iter->metric_prefix] / MP_array[(char)i.metric_prefix],iter->dimen.power);
        }
        all_magnitude *= magni;
    }
    return all_magnitude;
}
```

=== 错误定义

在这里作者并未自定义错误，全部采用`std::exception`错误（毕竟是演示）

=== 加减


对于加减的计算，先是要比较其量纲单位是否匹配，后是尺度转换，再是相加
因而其返回值为`std::expected`。
同时应返回的`basic_unit`要取二者共有的类型，即`std::common_type_t<magnitude_t,M>`等

==== 加减函数

以加法函数为例，错误在返回值中传出而非直接抛出
以下为函数声明：

注：在以下情形中，`V`、`M`、`P`类型都是由`std::common_with`进行约束
```cpp
constexpr std::expected<
    basic_unit<
        std::common_type_t<value_t,V>,
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >,
    std::exception
> plus(const basic_unit<V,M,P>& unit) const noexcept;
```

而在函数中为比较量纲，那么

1. 容器大小相同，即`size`相同
2. 由于使用的容器`std::set`为有序容器，即可直接按顺序比较即可。因为顺序不同时二者一定不同

最终返回公共类型

以下为函数实现：

注：不同模板之间无法访问私有变量，所以只能从公开接口获取
```cpp
if (dimens.size() == unit.getDimensions().size()) {
    auto i = dimens.begin();
    auto j = unit.getDimensions().begin();
    for (;i != dimens.end() && j != dimens.end();) {
        if (!i->type_equal(*j))
            return std::unexpected(std::exception());
        i++;
        j++;
    }
    return basic_unit<
        std::common_type_t<value_t,V>,
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >(value + MagnitudeCalculateFrom(unit) * unit.getValue(),dimens);
}
else return std::unexpected(std::exception());
```

同理可得到减法函数

==== 加减运算符

套用加减函数并抛出可能的错误
以加法运算符为例

```cpp
auto u = plus(unit);
if (u.has_value())
    return u.value();
else throw u.error();
```

减法运算符同理

== 乘

对于乘法，其并没有任何的错误可被抛出

=== 乘法函数

以下为乘法的函数声明：

```cpp
constexpr basic_unit<
    std::common_type_t<value_t,V>,
    std::common_type_t<magnitude_t,M>,
    std::common_type_t<power_t,P>
> multiply(const basic_unit<V, M, P>& unit) const noexcept;
```

对于乘法而言无需去比较量纲，但需要去尝试去找出相对应的量纲并在指数上相加，如果找不到就插入该找不到的量纲。

以下为函数实现：

```cpp
std::set<
    basic_MP_dimension<
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >,
    MP_dimension_less<
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >
> tmp_dimens;
for (auto i : dimens){
    auto dimen = basic_MP_dimension<M, P>::convert(i);
    basic_dimension<
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    > tmp_dimen {
        i.dimen.magnitude,
        i.dimen.power,
        i.dimen.short_name,
        i.dimen.dimension_name,
    };
    if (auto iter = unit.getDimensions().find(dimen); iter != unit.getDimensions().end())
        tmp_dimen.power += iter->dimen.power;
    tmp_dimens.insert(
        basic_MP_dimension<
            std::common_type_t<magnitude_t,M>,
            std::common_type_t<power_t,P>
        > {
            i.metric_prefix,
            tmp_dimen
        }
    );
}
```

=== 乘法运算符

直接使用乘法函数即可

== 除

对于除法，与乘法相比需判断值是否为`0`

=== 除法函数

以下为除法的函数声明：

```cpp
constexpr std::expected<
    basic_unit<
        std::common_type_t<value_t,V>,
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >,
    std::exception
> devide(const basic_unit<V, M, P>& unit) const noexcept;
```

以下为函数实现：

```cpp
if (unit.getValue() == 0)
    return std::unexpected(std::exception());
std::set<
    basic_MP_dimension<
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >,
    MP_dimension_less<
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    >
> tmp_dimens;
for (auto i : dimens){
    auto dimen = basic_MP_dimension<M, P>::convert(i);
    basic_dimension<
        std::common_type_t<magnitude_t,M>,
        std::common_type_t<power_t,P>
    > tmp_dimen {
        i.dimen.magnitude,
        i.dimen.power,
        i.dimen.short_name,
        i.dimen.dimension_name,
    };
    if (auto iter = unit.getDimensions().find(dimen); iter != unit.getDimensions().end())
        tmp_dimen.power -= iter->dimen.power;
    tmp_dimens.insert(
        basic_MP_dimension<
            std::common_type_t<magnitude_t,M>,
            std::common_type_t<power_t,P>
        > {
            i.metric_prefix,
            tmp_dimen
        }
    );
}
return basic_unit<
    std::common_type_t<value_t,V>,
    std::common_type_t<magnitude_t,M>,
    std::common_type_t<power_t,P>
>(value / (MagnitudeCalculateFrom(unit) * unit.getValue()),tmp_dimens);
```

=== 除法运算符

使用并抛出（如有）除法函数中的错误

= 总代码

位于`github` 仓库中 #link("https://github.com/Bendancom/BlogCodes")[https://github.com/Bendancom/BlogCodes]

= TODO

- 添加错误分类
- 重载`std::formatter`
- 四则运算的运算至函数与运算符（e.g. `operator+=`与`plusto`）
- 从字符串中转化（估计要等到cpp26了，静态反射）
- 添加静态检验（估计要到cpp26了，容器库实现`constexpr`常量表达式初始化）

#bibliography("refs.yml")
