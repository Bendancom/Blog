#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/physica:0.9.8": vb
#import "@preview/zero:0.7.0": num, quan
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#show: post.with(
  title: [Units Library Implementation],
  subtitle: [Implementation Approach],
  date: datetime(year: 2026, month: 10, day: 21),
  lastModDate: none,
  authors: "Bendancom",
  description: [Physical laws in the real world all require physical units. Compared with computing directly on numbers, computations involving physical quantities allow dimensional validation and unit conversion.],
  tags: ("Units", "Physics", "Implementation", "Dimension"),
  category: "Technology",
  order: 2,
  image: none,
  lang: "en",
)

= Programming Language Requirements

Recommended programming language support:

- Compile-time constants and evaluation
- Vector types and SIMD
- Namespaces

These capabilities place most of the computation of dimensions, units, and transformation matrices at compile time, reducing runtime computation or accelerating it. Namespaces make it convenient to categorize various constants.

= Dimensions

== Extending the Dimensions of the Three Major Unit Systems

It is known which base dimensions the three major unit systems have:

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: center,
    table.header[International System of Units][Gaussian System][Natural System],
    [
      Length $L$ \
      Mass $M$ \
      Time $T$ \
      Electric current $I$ \
      Thermodynamic temperature $Theta$ \
      Amount of substance $N$ \
      Luminous intensity $J$
    ],
    [
      Length $L$ \
      Mass $M$ \
      Time $T$
    ],
    [
      Energy $E$
    ],
  ),
  caption: [Base dimensions of the three major unit systems],
)

The table above lists the "base dimensions" of each system, not all the physical quantities they can describe. The natural system usually sets
$c = ℏ = k_B = 1$, leaving only energy as an independent basis when considering only mechanical and thermal quantities; the Gaussian system also lists only
$L$, $M$, $T$. As bases, they are not complete: quantities such as temperature and luminous intensity require additional constants or extended bases. The approach in this article is to extend the bases to a uniform dimension count, so that every physical quantity has a well-defined dimensional representation in any unit system.

=== Linearity

First, a premise: the "elimination" below is not a property of SI itself, but a result obtained after fixing specific physical constants to dimensionless numbers in certain unit systems.

- In the Gaussian system, setting $4 pi epsilon.alt_0 = 1$ in Coulomb's law allows the dimension of current/charge to be expressed in terms of length, time, and mass.
- In the natural system, setting $k_B = 1$ makes temperature and energy have the same dimension; setting $ℏ = c = 1$ further allows length, time, and mass to be expressed in terms of energy.
- Luminous intensity involves the luminous efficacy of photometry and cannot be derived from $L M T$ by radiant intensity alone.
  This article therefore does not treat luminous intensity as an independent basis, but replaces it with a combination of radiant intensity and solid angle/rotation dimension; see below for details.

Therefore, the seven base dimensions of SI are not themselves "linearly dependent"; basis redundancy only appears after fixing the above constants. To place the three major unit systems into the same invertible transformation framework, they must be extended to bases with the same dimension count.

Temperature requires a separate explanation: absolute temperature (temperature scale) transforms affinely, while temperature difference transforms linearly. Therefore, later we split temperature into two directions, "temperature scale" and "temperature difference"; in the natural system, temperature difference is related to energy through $k_B Delta T$.

=== Uniqueness

We should ensure that, among the modeled kinds of physical quantities, every dimensional combination has a unique interpretation. The most direct example is torque and energy:

$
  [E] = M L^(2) T^(-2) \
  [tau] = M L^(2) T^(-2)
$

The two have the same dimension in SI, but different physical meanings: energy is a scalar, and torque is a pseudovector. To distinguish them, the rotation dimension $Omega$ is introduced: energy takes $Omega^0$, and torque takes $Omega^1$. Note that this can only distinguish parity/rotation properties, not all kinds of physical quantities; for other conflicting physical meanings, dimensions must be added according to the definitions.

Another example is capacitance:

#table(
  columns: (1fr, 1fr, 1fr),
  align: center,
  table.header[International System of Units][Gaussian System][Natural System],
  [$L^(-2) M^(-1) T^4 I^2$], [$S L$], [$E^(-1)$],
)

In the Gaussian and natural systems, without introducing $S$ and constant bases, capacitance would have the same dimension as length and time respectively, causing ambiguity. After introducing $S$, capacitance is written as $S L$ in the Gaussian system and as $E^(-1)$ in the natural system (which is $T$ when $H = 1$). Thus the dimensional combination carries electromagnetic/energy information and is no longer confused with pure length or pure time.

=== Summary

For the bases of the three major unit systems to express the physical quantities covered in this article and for the transformation matrices to be invertible, each system must have the same number of bases. This article ultimately unifies them into 8 basis directions:

- SI: $L$, $M$, $T$, $I$, temperature scale $Theta$, temperature difference $Delta$, $N$, rotation $Omega$
- Gaussian: $L$, $M$, $T$, electromagnetic $S$, $Theta$, $Delta$, $N$, $Omega$
- Natural: $E$, $C$, $K$, $Delta$, $H$, $S$, $N$, $Omega$
  (these are "constant bases", not dimensions in the usual sense)

Luminous intensity $J$ is no longer treated as an independent basis here; photometric quantities require additional luminous efficacy semantics and cannot be represented by dimensions alone.

After this treatment, the unit systems become:

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: center,
    table.header[International System of Units][Gaussian System][Natural System],
    [
      Length $L$ \
      Mass $M$ \
      Time $T$ \
      Electric current $I$ \
      Temperature scale $Theta$ \
      Temperature difference $Delta$ \
      Amount of substance $N$ \
      Rotation $Omega$
    ],
    [
      Length $L$ \
      Mass $M$ \
      Time $T$ \
      Electromagnetic $S$ \
      Temperature scale $Theta$ \
      Temperature difference $Delta$ \
      Amount of substance $N$ \
      Rotation $Omega$
    ],
    [
      Energy $E$ \
      Speed of light $C$ \
      Boltzmann constant $K$ \
      Boltzmann difference $Delta$ \
      Planck constant $H$ \
      Elementary charge $S$ \
      Amount of substance $N$ \
      Rotation $Omega$
    ],
  ),
  caption: [The extended three major unit systems],
)

> Note: The current repository code uses 7 bases (without $Delta$); the 8-dimensional table in this section is the theoretical design; the implementation has not yet added $Delta$. Readers comparing with the code should note this difference.

= Mathematical Computation

The matrix inverse is computed using `Python`'s `Sympy`, and the result is written into the implementation as a compile-time constant, avoiding a runtime dependency on a linear algebra library.

== SI $<->$ Gaussian $<->$ Natural

For these transformations, one unit system is used as the basis; here the International System of Units is chosen. Let $T_(X -> Y)$ be the matrix that transforms the dimension exponent vector of system $X$ to system $Y$, and let $h(vb(u); vb(t)) = vb(t)^(dot.o vb(u))$ be the numerical scaling. Then:

$
  T_(B -> C) = T_(A -> C) T_(A -> B)^(-1) \
  T_(B -> C)^(-1) = T_(A -> B) T_(A -> C)^(-1)
$

Numerical factors are analogous, but since it is scalar multiplication, the order is commutable:
$
  h(vb(u); vb(t)_(B -> C)) & = h(vb(u); vb(t)_(A -> C)) h^(-1) (vb(u); vb(t)_(A -> B)) \
  h(vb(u); vb(t)_(B -> C)) & = h(vb(u); vb(t)_(A -> C) times.o vb(t)_(A -> B)^(times.o (-1)) )
$

=== Dimension Exponent Transformation

For the International System of Units, $quan("1 C") = quan("1 A") dot quan("1 s")$, i.e., the coulomb is defined by the two dimensions of current and time.

But for the Gaussian system, its definition of the coulomb is derived from `Coulomb`'s law:

$
  F = epsilon.alt_0 frac(Q_1 Q_2, r^2)
$

Defining the electromagnetic dimension with the vacuum permittivity as the reference#footnote[This reference can absolutely be replaced by vacuum permeability, electric field strength, magnetic flux density, or anything else related to electromagnetism], the relation between the electromagnetic dimension and the International System of Units is:
$
  S = L^(-3) M^(-1) T^(4) I^(2)
$

Solving $S = L^(-3) M^(-1) T^4 I^2$ for $I = S^(1/2) L^(3/2) M^(1/2) T^(-2)$ gives the exponents $1.5$, $0.5$, $-2$, and so on associated with the $S$ column in the matrix.

The following matrices use the column-vector convention: the left side is the target system's exponents, and the matrix on the right multiplies the source system's exponents; the columns of the matrix are the dimension vectors of the source system's bases in the target system. That is, the transformation matrix and its inverse are:
$
  vec(g_L, g_M, g_T, g_Theta, g_Delta, g_S, g_N, g_Omega) = vb(A)_("SI" <-> "Gauss") vec(s_L, s_M, s_T, s_Theta, s_Delta, s_I, s_N, s_Omega) \
  vb(A)_("SI" <-> "Gauss") = mat(
    1, 0, 0, 0, 0, 1.5, 0, 0;
    0, 1, 0, 0, 0, 0.5, 0, 0;
    0, 0, 1, 0, 0, -2, 0, 0;
    0, 0, 0, 1, 0, 0, 0, 0;
    0, 0, 0, 0, 1, 0, 0, 0;
    0, 0, 0, 0, 0, 0.5, 0, 0;
    0, 0, 0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 0, 0, 1;
  )
  vb(A)^(-1)_("SI" <-> "Gauss") = mat(
    1, 0, 0, 0, 0, -3, 0, 0;
    0, 1, 0, 0, 0, -1, 0, 0;
    0, 0, 1, 0, 0, 4, 0, 0;
    0, 0, 0, 1, 0, 0, 0, 0;
    0, 0, 0, 0, 1, 0, 0, 0;
    0, 0, 0, 0, 0, 2, 0, 0;
    0, 0, 0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 0, 0, 1;
  )
$

For the natural system, most dimensions are represented using constants. The matrix likewise follows the "target system on the left, source system on the right" column-vector convention:
$
  vec(s_L, s_M, s_T, s_Theta, s_Delta, s_I, s_N, s_Omega)
  = vb(A)_("Natural" -> "SI") vec(n_E, n_C, n_K, n_Delta, n_H, n_S, n_N, n_Omega) \
  vb(A)_("Natural" -> "SI") = mat(
    2, 1, 2, 2, 2, 0, 0, 0;
    1, 0, 1, 1, 1, 0, 0, 0;
    -2, -1, -2, -2, -1, 1, 0, 0;
    0, 0, -1, 0, 0, 0, 0, 0;
    0, 0, 0, -1, 0, 0, 0, 0;
    0, 0, 0, 0, 0, 1, 0, 0;
    0, 0, 0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 0, 0, 1;
  )
  vb(A)^(-1)_("Natural" -> "SI") = mat(
    -1, 1, -1, 1, 1, 1, 0, 0;
    1, -2, 0, 0, 0, 0, 0, 0;
    0, 0, 0, -1, 0, 0, 0, 0;
    0, 0, 0, 0, -1, 0, 0, 0;
    1, 0, 1, 0, 0, -1, 0, 0;
    0, 0, 0, 0, 0, 1, 0, 0;
    0, 0, 0, 0, 0, 0, 1, 0;
    0, 0, 0, 0, 0, 0, 0, 1;
  )
$

Note: $Delta$ in the natural system matrix is a formal basis; to interpret $Delta$ as temperature difference, the physical meaning of the matrix must be rechecked.

=== Dimensional Numerical Transformation

The Gaussian system sets the Coulomb constant in `Coulomb`'s law from $frac(1, 4 pi epsilon.alt_0)$ to #num(1), which gives its change factor:
$
  t_I = frac(1, sqrt(4 pi epsilon.alt_0)) \
  t'_S = 4 pi epsilon.alt_0
$
Under the old SI convention $\mu_0 = 4 pi times 10^(-7) "H/m"$, we have:
$
  4 pi epsilon.alt_0 = frac(10^7, c^2)
$
where $c$ takes the SI value. This yields (in the order $L, M, T, Theta, Delta, S, N, Omega$):
$
  vb(t)_("SI" <-> "Gauss") = vec(1, 1, 1, 1, 1, frac(c, 10^(3.5)), 1, 1) \
$

Since the natural system mostly uses constants, we obtain (in the order $E, C, K, Delta, H, S, N, Omega$):
$
  vb(t)_("SI" <-> "Natural") = vec(1, frac(1, c), frac(1, k), frac(1, k), frac(1, h), frac(1, e), 1, 1) \
$

= Approach

#figure(
  canvas({
    import fletcher.shapes: diamond, ellipse, rect
    diagram(
      node-stroke: 1pt,
      node-corner-radius: 0.5em,

      node((0, 0), [Dimension]),
      edge((0, 0), (0, 1), "-|>"),
      node((0, 1), [Dimension Combination]),
      edge((0, 1), (0, 2), [Register], "-|>"),
      node((0, 2), [Physical Meaning]),

      node((1, 2), [Magnitude]),
      edge((1, 2), (0, 2), [Register], "-|>"),
      edge((1, 2), (1, 1), [Register Base Magnitude], "-|>"),

      edge((0, 0), (1, 0), (1, 1), [Register], "-|>"),
      node((1, 1), [Unit System / Generic]),
      edge((1, 1), (0, 1), "-|>"),
    )
  }),
  caption: [Units Library Architecture],
)

Seeing this mutually cross-referencing diagram, does it feel confusing? In such a relationship diagram, "Register" means that the dependency is the index at the arrow's origin.

The units library should contain the following:

- Units (combined dimensions)
- Quantities (numbers, matrices, tensors)

Thus the difficulty lies in units; everything in the units library revolves around units, and quantities are merely incidental content (although in computation they are the main part).

Through the use of generics, all the number fields that need to be used in the units library can be uniformly standardized:

- Real number field
- Rational number field
- Integer field

They are not standardized separately, e.g., using `int` for centimeters and `float` for feet in the length dimension. First, for optimization; separate standardization would cause:

- Inability to perform `SIMD` optimization: variables of different types that cannot be implicitly converted cannot use vectorization to accelerate computation
- If high-precision numbers are used, runtime conversion incurs a performance overhead

For all data storage, to achieve maximum extensibility while saving memory, the singleton design pattern is adopted, using unique identifiers, with container lookup to retrieve detailed data.

To achieve $cal(O) (1)$ access speed, pointers are used as unique identifiers and also as the means to access data.
For programming languages that do not expose pointers, the unique identifier is defined by the user, and a hash container is used to look up and access data.

Approaches that can use this method include:

- Dimension types
- Unit systems
- Metric prefixes
- Magnitudes
- Physical meanings

This method is equivalent to registering in a globally unique container when the type is initialized.

== Dimensions

Dimension kinds are complex and vary with actual circumstances. For example, computer graphics involves the pixel unit, which cannot be classified under length and can only be listed separately.

Here, metric prefixes and units are separated, which facilitates extension: there is no need to implement different metric prefixes for the same unit.

Dimensions also belong to unit systems. Some are independent of all unit systems, such as pixels; some are shared by two unit systems, such as length, which can be used in both the Gaussian system and the International System of Units.

Therefore, the dimension type should be a marker containing:

- Dimension name, represented by a string
- Dimension short name, using a `Unicode` character as the short name

== Unit Systems

The role of a unit system is to declare which dimension types belong to it, for convenience of use.

That is, at compile time or runtime, package at least three of:

- Dimensions
- Dimension transformation
- Inverse dimension transformation (one of the previous two may be chosen)
- Dimensional numerical conversion
- Inverse dimensional numerical conversion (one of the previous two may be chosen)

into a container, using the International System of Units as the reference; unit system transformations then use this content as the dependency for transformation and inverse transformation. In addition, unregistered dimension types remain unchanged if conversion is needed.

Then each unit system has its own array to store data, which is inconvenient for custom unit systems. So the unit systems are packaged again into a global key-value container in which the array of the corresponding unit system can be queried.

Summarizing the above, a unit system structure should contain:

- Container
  - Dimension types
  - Dimension transformation
  - Inverse dimension transformation
  - Dimensional numerical transformation
- Unit system name

This is still inconvenient for defining dimensions. Now move the unit system registration process into dimension definition, so that initializing a dimension becomes:

- Dimension name, represented by a string
- Dimension short name, using a `Unicode` character
- Owning unit system
- Dimension transformation
- Inverse dimension transformation (one of the previous two may be chosen)
- Dimensional numerical conversion
- Inverse dimensional numerical conversion (one of the previous two may be chosen)

== Dimension Combinations

For the energy dimension of the natural system, it can be converted to a dimension combination of the International System of Units, and is therefore defined as:

- Owning unit system
- Set container
  - Dimension
  - Exponent

These are the dimension exponent set representations of physical units; which unit to take should be decided by magnitudes.

=== Exponents

The range of exponent values usually depends on the dimension of the dimension it needs to express; the number field of its values should satisfy both a multiplicative group and an additive group, and rational numbers are generally used.

== Physical Units

A base unit contains the following:

- Metric prefix
- Magnitude
- Exponent

A complex physical unit is a combination of these.

Since the same physical meaning has different dimensional representations in different unit systems, physical meaning is abstracted as the platform for establishing magnitudes.

For physical quantities, how to output their units is also a problem: some need to output the simplest unit, while others need to preserve the unit combination written by the user to express physical relations. The author's approach is to define a cost function for candidate unit combinations, sort them from smallest to largest cost, and take the first combination satisfying the constraints. The cost can use the $L_1$ or $L_2$ norm of the dimension exponent vector, plus the constraint that "the distance to the target unit must be less than a given threshold"; the specific norm and threshold are specified by the caller. For example, energy can be output as `J`, or as `kg m^2 / s^2` or `N m`, decided by the cost function.

For the simplest metric prefix problem, such as #quan("L / km"), the unit structure written by the user is preserved by default, and dimensions or prefixes are not automatically eliminated; that is, it will not be automatically simplified to #quan("mm^2"). Whether to simplify is explicitly requested by the caller.

== Magnitudes

A magnitude transformation is a transformation from one basis to another in a linear transformation.

There are two approaches:

- Absolute basis: all transformations are converted through a single unit. Advantages: reduced memory consumption; disadvantages: every dimensional transformation requires an operation on each dimension, wasting compute in large-scale computations.
- Relative basis: every conversion from one unit to another has a direct conversion factor. Advantages: saves compute; disadvantages: memory usage is $cal(O) (C_n^2)$.

In the implementation, the absolute basis is a proper subset of the relative basis, so the absolute basis cannot be bypassed. The two methods have their own merits and can be used together, distinguished by compile-time parameters.

Construct a container to store the relative values between magnitudes for use in transformation operations, automatically registered when a magnitude is initialized.

Therefore, a magnitude should contain:

- Magnitude factor
- Affine offset (only used for pure temperature dimensions)
- Magnitude name
- Magnitude short name
- Physical meaning
- Owning unit system (or determined indirectly through physical meaning)

The affine offset is used for temperature scales such as Celsius and Fahrenheit; the offset for temperature-difference magnitudes is 0. The magnitude factor should be nonzero and satisfy multiplication in the corresponding number field; temperature magnitudes as a whole form an affine transformation and cannot be described by a multiplicative group alone.

=== Physical Meaning

Note that physical meaning is used here to describe magnitude ownership, because due to unit system issues, different unit systems have different bases. To ensure a unique corresponding physical meaning, it is abstracted into a general platform for use.

It should contain:

- Dimension combination
- Physical meaning name
- Physical meaning short name

=== Metric Prefixes

The following metric prefixes exist:

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: (center, center, center, center),
  table.header([Factor], [English Name], [Symbol], [Chinese Name]),

  // Data rows (large -> small)
  [$10^(30)$], [quetta], [Q], [昆],
  [$10^(27)$], [ronna], [R], [容],
  [$10^(24)$], [yotta], [Y], [尧],
  [$10^(21)$], [zetta], [Z], [泽],
  [$10^(18)$], [exa], [E], [艾],
  [$10^(15)$], [peta], [P], [拍],
  [$10^(12)$], [tera], [T], [太],
  [$10^(9)$], [giga], [G], [吉],
  [$10^(6)$], [mega], [M], [兆],
  [$10^(3)$], [kilo], [k], [千],
  [$10^(2)$], [hecto], [h], [百],
  [$10^(1)$], [deca], [da], [十],
  [$10^(-1)$], [deci], [d], [分],
  [$10^(-2)$], [centi], [c], [厘],
  [$10^(-3)$], [milli], [m], [毫],
  [$10^(-6)$], [micro], [µ], [微],
  [$10^(-9)$], [nano], [n], [纳],
  [$10^(-12)$], [pico], [p], [皮],
  [$10^(-15)$], [femto], [f], [飞],
  [$10^(-18)$], [atto], [a], [阿],
  [$10^(-21)$], [zepto], [z], [仄],
  [$10^(-24)$], [yocto], [y], [幺],
  [$10^(-27)$], [ronto], [r], [柔],
  [$10^(-30)$], [quecto], [q], [亏],
)

The storage of metric prefixes can also be classified:

- Store the exponent. Advantages: saves memory, high precision; disadvantages: wastes compute.
- Store the relative value. Advantages: saves compute; disadvantages: memory usage is $cal(O) (C_n^2)$, and there are precision issues.

In the implementation, the absolute basis is a proper subset of the relative basis, so the absolute basis cannot be bypassed. The two methods have their own merits and can be used together, distinguished by compile-time parameters.

Besides International System of Units prefixes, there is also a technical standard based on #num(1024) rather than #num(10)—the `KiB` family—so metric prefixes should also use generics, i.e., store the base and the exponent. Within the same series, all factors are integer powers of some base; this base is the series' base (decimal #num(10), binary #num(1024)). For this standard, there is no part with negative exponents, so we obtain:

#table(
  columns: (auto, auto, auto, auto),
  align: (center, center, center, center),
  table.header([Factor], [English Name], [Symbol], [Chinese Name]),

  [$1024^(1)$], [kibi], [Ki], [千比],
  [$1024^(2)$], [mebi], [Mi], [兆比],
  [$1024^(3)$], [gibi], [Gi], [吉比],
  [$1024^(4)$], [tebi], [Ti], [太比],
  [$1024^(5)$], [pebi], [Pi], [拍比],
  [$1024^(6)$], [exbi], [Ei], [艾比],
  [$1024^(7)$], [zebi], [Zi], [泽比],
  [$1024^(8)$], [yobi], [Yi], [尧比],
  [$1024^(9)$], [robi], [Ri], [罗比],
  [$1024^(10)$], [quebi], [Qi], [昆比],
)

For a series, the base is the same and the exponents differ, so metric prefixes can be abstracted as constructed from a base class containing:

- Base
- Exponent
- Value, automatically computed at compile time as needed, or not computed

Then construct a key-value container holding the relative values corresponding to these metric prefixes, whose contents are automatically registered when the base class is initialized.

The number field of its values should satisfy a multiplicative group, and generic constraints should enforce this in the implementation. Generally, rational numbers are used for the base and integers for the exponent.

== Parallelism

Parallel optimization generally splits large elements into blocks for parallel computation, then optimizes within blocks into multiple vectorized computations.

=== SIMD

This optimization depends entirely on the programming language and data types used. First, the programming language must support SIMD optimization; second, it depends on the data type—whether it is a vectorizable data type or a user-defined high-precision data type.

Assume all data types are `FP64`; the following aspects can be optimized:

- `Hadamard` power: element-wise power
  - Fast exponentiation
- `Hadamard` product: element-wise product

=== MIMD

This optimization is arguably the most universal, but it is not suitable for computation between just two data items, otherwise the overhead of parallelism exceeds its benefit, so it is only suitable for large amounts of physical quantity computation and dimensional conversion.

This optimization should be left to the user to decide.
