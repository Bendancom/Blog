
= 代码

== 量纲

=== 单位制词头

== 幂函数

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
