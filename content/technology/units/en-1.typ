#import "/typ/post.typ": post
#import "/typ/lib.typ": *
#import "@preview/physica:0.9.8": dmat, va, vb
#import "@preview/zero:0.7.0": num, quan

#show: post.with(
  title: [Units Library Implementation],
  subtitle: [Theoretical Understanding],
  date: datetime(year: 2026, month: 8, day: 7),
  lastModDate: none,
  authors: "Bendancom",
  description: [Physical laws in the real world all require physical units. Compared with computing directly on numbers, computations involving physical quantities allow dimensional validation and unit conversion.],
  tags: ("Units", "Physics", "Theory", "Dimension"),
  category: "Technology",
  order: 1,
  image: none,
  lang: "en",
)

= Prerequisites

- Linear algebra
- Group theory (involves mathematical understanding; may be skipped)
- Some physics understanding (dimensions)

= Physical Understanding

== Dimensions and Systems of Units

A dimension is a fundamental attribute of a physical quantity, used to describe the category and nature of the quantity.

A system of units is a set of dimensions, such as:

- The International System of Units
- The Gaussian system of units
- The natural system of units

== Units

Units fall into the following two categories:

- Base units, i.e., units containing only one dimension
- Derived units, i.e., units containing multiple dimensions


=== Metric Prefixes <metricPrefix>

Metric prefixes describe how much a physical quantity has been scaled. Unlike magnitudes, they do not change the unit but merely abbreviate the numerical value; their purpose is to greatly shorten the expression of irrelevant numerical parts,
for example, #quan[1 Gm] and #quan[1000000000 m] are physically identical, but the former is more concise and intuitive.

=== Magnitudes <magnitude>

Not every dimension corresponds to only one base unit; the relation between them is surjective but not injective. For example, both feet and meters are base units describing the single dimension of length.

Therefore, magnitudes are used to describe the scaling ratio between base units (except temperature, which is an affine transformation).
For example, the magnitude of feet relative to meters is #num(0.3048), meaning that to convert from feet to meters, the numerical value must be scaled by #num(0.3048).

= Mathematical Understanding

Simply put, dimensions can be regarded as the basis in linear algebra; a system of units is the coordinate system formed by this set of basis vectors; and the unit of a physical quantity is its coordinate in that coordinate system.

== The Algebraic Nature of Dimensions

Let the set of dimensions be $D$ and the set of physical units be $U$.
Under multiplication, $U$ forms a free abelian group, and $D$ is the natural generating set of $U$. The theory is as follows:

- Associativity: $L M T^(-2) = L(M T^(-2))$
- Closure: operations on dimensions do not produce new dimensions
- Identity: the "dimension" of a dimensionless number is the identity element among dimensions, denoted here as #num(1)
- Inverse: operations between dimensions can cancel each other to yield the identity element.
- Commutativity: $L M T^(-2) = M T^(-2) L$
- Multiplication: the group operation is denoted by the multiplication symbol
- Free: all physical units are formed from dimensions as a basis.

Construct a mapping $f$ here, letting:
$
  f: U -> QQ^(n)
$
The mapping $f$ maps $U$ into the additive group of rational numbers, and the two are isomorphic. The theory is as follows:

- Homomorphism: $f(u_1 dot u_2) = f(u_1) + f(u_2)$
- Injectivity: if $f(u_1) = f(u_2)$, then $u_1 = u_2$
- Surjectivity: $forall x in QQ^(n),exists u in U$, such that $f^(-1)(x) = u$

Isomorphism means that, in terms of algebraic structure, $U$ and $QQ^(n)$ are indistinguishable.

Here, $QQ^(n)$ under this mapping is generally called the dimension exponent set, and the resulting $QQ$ components are called dimension exponents.

== `Hadamard` Operations

The `Hadamard` operation is an element-wise operation on two tensors of the same dimension and order. It is explained here to simplify the formulas.

A vector is a first-order tensor, and a matrix is a second-order tensor.

`Hadamard` product: element-wise product

$
  vb(a) dot.o vb(b) = vec(a_1 b_1, dots.v, a_n b_n)
$
`Hadamard` power: element-wise power

$
  vb(a)^(dot.o vb(b)) = vec(a_1^(b_1), dots.v, a_n^(b_n))
$

== Norm

Refers to how to measure the distance between two points in the same coordinate system, in the form:
$
  cal(l)_n (vb(x)) = norm(vb(x))_n = root(n, sum_(i=1)^(n)x_i^n)
$

== $dim(vb(v))$

Refers to finding the dimension of $vb(v)$; it can be a matrix, a vector space, a vector, or anything else that has a concept of dimension.

= Theoretical Understanding

Since the transformations between the vast majority of physical units are linear, and only quantities under a single dimension are affine transformations (yes, temperature, I am talking about you), consider the general case first, then the special cases.

== General

Dimension exponents cannot serve directly as the basis for transforming unit values; a mapping must be constructed.

=== Dimensional Transformation

For a physical quantity with an invariant combination of dimensions, the following affect its value:

- #link(<metricPrefix>)[Metric prefixes]
- #link(<magnitude>)[Magnitudes]

Thus we can construct a mapping from the dimension exponent set to the set of relative numerical transformation factors:
$
  g: QQ^(n) -> RR^(n)
$

Note that this mapping is injective, i.e., the dimension exponent set cannot be recovered from the set of relative numerical transformation factors.

Consider first the single-dimension case:
$
  frac(x', x) = (frac(m', m))^(p) (frac(t', t))^(p)
$
That is, one coordinate component of the mapping $g$ is:
$
  g_n (u_n) = (frac(m' t', m t))^(u_n)
$

Where:
- $m$ original metric prefix
- $m'$ current metric prefix
- $t$ original magnitude
- $t'$ current magnitude
- $p$ original dimension exponent
- $p'$ current dimension exponent
- $x$ original value
- $x'$ current value
- $u_n$ dimension exponent component

Generalizing this to multiple dimensions, the mapping $g$ is:

$
  g(vb(u); vb(p),vb(m)) = (vb(m) dot.o vb(t))^(dot.o vb(u))
$

Where:
- $vb(p)$ relative metric prefix vector
- $vb(m)$ relative magnitude vector

Note that we do not need the corresponding change for each dimension, only the total change:

$
  v_"dim" = product_(i=1)^(n) g_(i) (vb(u); vb(p), vb(m))
$

Where:

- $v_"dim"$ dimensional transformation factor

=== Unit System Transformation

The essence of a unit system transformation is a linear mapping from one vector space representing a dimension exponent set to another vector space representing a dimension exponent set.

For the mapping, by the rank-nullity theorem:
$
     dim(V) & = dim(ker T) + dim (im T) \
  dim(im T) & lt.eq.slant dim(V)
$

Where:

- $V$ original vector space
- $T$ mapped vector space
- $im T$ image of the mapped vector space
- $ker T$ kernel of the mapped vector space

That is, a linear mapping from a higher-dimensional vector space to a lower-dimensional vector space may cause a loss of dimension in the image space. To ensure the uniqueness of the physical meaning corresponding to dimensions, a change of basis is added to the unit system so that their dimensions are equal.

Let the mapping matrix be $A in QQ^{n times n}$; then the mapping is:
$
  vb(u)' = vb(A) vb(u)
$

Then comes the numerical scaling of physical quantities in a unit system transformation.

Define a mapping $h$ that maps the dimension exponent vector to the transformation factor vector:
$
  h(vb(u); vb(t)) = vb(t)^(dot.o vb(u))\
  h^(-1) (vb(u)'; vb(t)') = (vb(t)')^(dot.o (- vb(u)'))
$

Where:
- $vb(t)$ transformation factor vector

Then the final total transformation factor is:
$
  v_"unit" = product_(i=1)^(m) h_i (vb(u_m); vb(t))\
  v_"unit"^(-1) = product_(i=1)^(m) h^(-1)_i (vb(u'_m); vb(t)')
$

== Special Cases

=== Pseudovectors, Pseudoscalars, and Pseudotensors

Pseudovectors, pseudoscalars, and pseudotensors are physics concepts that refer to physical quantities whose chirality changes under spatial inversion; typical examples are torque, angular momentum, angular velocity, angular impulse, and so on.

For example, spatial inversion is like a mirror: outside the mirror is left-handed, and inside the mirror is right-handed (taking oneself as the reference frame).

Taking torque as an example, its pseudoscalar is $abs(vb(F))abs(vb(r))sin theta$. However, physics does not distinguish this, so if dimensions are matched, torque has the same dimension as energy, both being $M^(1)L^(2)T^(-2)$, and the two are equivalent to each other.

Therefore, to distinguish them, parity must be separated out as an independent dimension. Parity itself is also related to the parity of the angular dimension exponent. Combining the two, this dimension can be called the "rotation dimension", denoted $Omega$.

Note that for the rotation dimension, all odd powers indicate that the physical unit is a pseudoscalar/pseudovector/pseudotensor, and all even powers indicate that the physical quantity is a true scalar/true vector/true tensor.

For its physical meaning, we have:
- $Omega$ angle
- $Omega^(2)$ solid angle
- $Omega^(-1)$ per angle
- $Omega^(-2)$ per solid angle

Adding this dimension will affect physical quantities, metric tensors, and mathematical formulas.

For curvilinear coordinate systems, the added rotation dimension will inevitably add negative rotation dimension exponents to the angle-related metric components in the metric tensor to cancel this effect.

For mathematical formulas, what is affected are trigonometric function formulas, expressed as functionals:
$
  F[k] = k(frac(theta, quan("rad")))
$

Where:

- $k$ any trigonometric function

For physical quantities, angular velocity, angular momentum, angular impulse, and torque:
$
  vb(omega) = frac(vb(r) times vb(v), norm(vb(r))^(2)) quan("rad") \
  vb(L) = frac(1, quan("rad")) vb(r) times vb(p) \
  vb(Tau) = frac(1, quan("rad")) vb(r) times vb(I) \
  vb(M) = frac(1, quan("rad")) vb(r) times vb(F)
$

Where:

- $vb(L)$ angular momentum
- $vb(Tau)$ angular impulse
- $vb(M)$ torque
- $vb(p)$ momentum
- $vb(I)$ impulse
- $vb(F)$ force
- $vb(r)$ displacement

Similarly, the rotation dimensions added to these units can be generalized to all physical quantities that can be related by formulas to angular velocity, angular momentum, angular impulse, and torque.

Note that magnetic flux density is also related to angular momentum, through the angular momentum of the electromagnetic field. Of course, the most direct point is that magnetic flux density is an axial vector.

=== Temperature

When the temperature dimension exponent is #num(1), the transformation of temperature units is a linear function that does not pass through the origin.

- When temperature only means temperature difference, the difference can be ignored and only the temperature scale considered.
- In other cases, such as when temperature is the only dimension, both the temperature scale and the temperature difference must be considered.

#figure(
  table(
    columns: (auto, auto, auto),
    table.header[Temperature Dimension][Symbol][Function Converting to Kelvin],
    [Kelvin], [#quan("K")], [$K = T_K$],
    [Celsius], [#text(lang: "zh")[#quan("celsius")]], [$K = T_(degree upright(C)) + 273.15$],
    [Fahrenheit], [$degree upright(F)$], [$K = (T_(degree upright(F)) + 459.67) times 5 / 9$],
    [Rankine], [$degree upright(R)$], [$K = T_(degree upright(R)) times 5 / 9$],
    [Réaumur], [$degree upright(R e)$], [$K = T_(degree upright(R é)) times 5 / 4 + 273.15$],
    [Newton scale], [$degree upright(N)$], [$K = T_(degree upright(N)) times 100 / 33 + 273.15$],
    [Rømer scale], [$degree upright(R ø)$], [$K = T_(degree upright(R ø)) times 40 / 21 + 273.15$],
    [Delisle scale], [$degree upright(D e)$], [$K = 373.15 - T_(degree upright(D e)) times 2 / 3$],
  ),
  caption: [Various temperature scales],
)

There is only one method for this:

Separately define the affine transformation for the single temperature dimension; everything else can only be transformed linearly under identical temperature differences.

For physical quantities such as specific heat capacity and thermal conductivity, their temperature dimension represents the heat absorbed or conducted per unit temperature, i.e., the amount of temperature change. For such quantities, there is no difference between #quan("K") and #text(lang: "zh")[#quan("celsius")], but for a units library the two should be distinguished. To distinguish temperature from temperature change, $Delta #text(lang: "zh")[#quan("celsius")]$ and $Delta quan("K")$ can be introduced.

Also note that a temperature can be added to a temperature change, so the temperature dimension must be split into two dimensions: temperature difference and temperature scale. Use a linear mapping for the scale and an affine transformation for the difference, with a strict restriction on the range of dimension exponents.
