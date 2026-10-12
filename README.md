# Partitioned Quantity of Interest

A MATLAB library for computing partitioned quantities of interest (pQoIs)
and local field statistics from simulation profiles. The numerical core is
independent of the governing equations and can be used with both the
Kuramoto-Sivashinsky equation and minimal channel flow data.

The current implementation partitions one physical coordinate. Profile
arrays may have additional dimensions, so multiple time samples,
components, or parameter cases can be processed together. The API is
organized so that partitioning along multiple coordinates can be added
without changing the application-specific QoI definitions.

## Core idea

Given a local QoI density `q(x)` and partition edges
`x_0, x_1, ..., x_P`, the library computes

```text
Q_p = integral from x_(p-1) to x_p of q(x) dx.
```

Adjacent partitions share their boundary point. Consequently, summing all
partition integrals reproduces the integral over the covered domain, up to
the accuracy of the selected quadrature and interpolation.

## Requirements

- MATLAB R2021b or newer is recommended.
- No additional toolboxes are required for the library.
- MATLAB's unit-testing framework is used by the tests.

## Quick start

Clone the repository, open MATLAB in its root directory, and add it to the
path:

```matlab
addpath(pwd)
```

Create a grid, a local QoI profile, and partitions containing eight grid
intervals each:

```matlab
x = linspace(0, 64, 257).';
data.u = sin(2*pi*x/64);

energy = pqoi.qoi.ks.instantaneousEnergy(data);
partitions = pqoi.makeGridPartitions(x, 8);
partitionedEnergy = pqoi.integrate(x, energy, partitions);
```

Here, `8` means eight **grid intervals**, not eight points. Every full
partition therefore contains nine points. Its final point is also the first
point of the next partition.

Run the complete test suite with:

```matlab
run_tests
```

## Partition definitions

### Grid-aligned partitions

Use `pqoi.makeGridPartitions(x, a)` when each partition should span `a`
consecutive grid intervals:

```matlab
partitions = pqoi.makeGridPartitions(x, 16);
```

This is the preferred mode because every edge is an existing grid point.
It works for uniform and nonuniform grids. On a nonuniform grid, a
partition still contains 16 consecutive intervals, but its physical width
depends on the local spacing.

If the number of domain intervals is not divisible by `a`, the final
partition is shorter. This is recorded in
`partitions.hasShortFinalPartition`.

### Physical partition edges

Use `pqoi.makePhysicalPartitions` when the physical edges are prescribed:

```matlab
edges = linspace(x(1), x(end), 5);
partitions = pqoi.makePhysicalPartitions(x, edges);
Q = pqoi.integrate(x, q, partitions, 'Interpolation', 'pchip');
```

When an edge is absent from the grid, the profile is interpolated exactly
at that edge before trapezoidal integration. This is the fallback used by
the existing channel-flow postprocessing. Both `linear` and `pchip`
interpolation are supported.

## Relation to the original research code

The two original applications used related, but slightly different,
partition conventions:

- The KS `partitionQoIError` code generated shared index boundaries with
  `round(linspace(...))`. DNS bounds were selected using their nearest
  physical grid points.
- The early channel-flow `computePartitionData` code used a fixed number of
  points per partition and advanced the next partition from the previous
  final index, thereby sharing the edge.
- Later channel-flow scripts prescribed fixed physical edges and inserted
  interpolated profile values whenever an edge did not coincide with a
  grid point.

This library makes the convention unambiguous: `a` is the number of grid
intervals, adjacent partitions share an edge, and physical edges use
interpolation only when required. Regression tests reproduce the working
KS grid-aligned formula and the channel-flow physical-edge fallback.

## Comparing reference and approximate data

Reference and approximate profiles may use different grids:

```matlab
reference.coordinate = xDNS;
reference.profiles.energy = energyDNS;

approximation.coordinate = xLES;
approximation.profiles.energy = energyLES;

partitions = pqoi.makeGridPartitions(xLES, 8);
comparison = pqoi.compare(reference, approximation, partitions);
```

By default, partition errors follow the convention used in the research
scripts:

```text
100 * abs(Q_approx,p - Q_ref,p) / abs(Q_ref,total).
```

The result also contains the global error, both sets of partition
integrals, and their totals. `Normalization` can be set to
`reference-partition` or `none`, and `Scale` can be set to `1` when
fractions are preferred over percentages.

## Partition statistics

`pqoi.partitionStatistics` computes the mean, standard deviation, RMS,
minimum, maximum, integral, and physical width in every partition:

```matlab
fields.u = u;
fields.dudx = dudx;
stats = pqoi.partitionStatistics(x, fields, partitions);
```

The default `spatial` weighting integrates over physical distance and is
appropriate for nonuniform grids. To reproduce the unweighted `mean` and
`std` calls in the original channel-flow helper, use:

```matlab
stats = pqoi.partitionStatistics(x, fields, partitions, ...
    'Weighting', 'sample');
```

## Included QoI modules

KS definitions are under `+pqoi/+qoi/+ks`:

- `instantaneousEnergy`: `0.5*u.^2`
- `enstrophy`: `dudx.^2`
- `meanEnergy`: `0.5*meanU.^2`
- `fluctuatingEnergy`: `0.5*(meanU2-meanU.^2)`
- `totalEnergy`: `0.5*meanU2`

Minimal-channel definitions are under `+pqoi/+qoi/+channel`:

- `totalShearStress`
- `turbulentKineticEnergy`
- `production`, with optional SGS-stress inclusion

These modules only construct local profiles. Partitioning, integration,
statistics, and comparison remain in the shared core.

## Adding a QoI

A QoI module is an ordinary MATLAB function that accepts a data struct and
returns a numeric local profile:

```matlab
function q = scalarVariance(data)
q = data.meanPhi2 - data.meanPhi.^2;
end
```

It can be called directly or through the generic helper:

```matlab
q = pqoi.computeProfile(data, @scalarVariance);
Q = pqoi.integrate(x, q, partitions);
```

Keep solver-specific file parsing and variable naming in an application
adapter. Convert the output to a coordinate plus named numeric profiles
before passing it to the core routines.

## Arrays with additional dimensions

Profiles can contain additional dimensions. For example, `u` may have
shape `Nx-by-Nt`, with space along the first dimension:

```matlab
Q = pqoi.integrate(x, 0.5*u.^2, partitions);
```

The output has shape `Npartitions-by-Nt`. If space is stored along another
dimension, specify it explicitly:

```matlab
Q = pqoi.integrate(x, q, partitions, 'SpatialDimension', 2);
```

This array handling prepares the code for higher-dimensional simulation
fields while keeping the present partition geometry intentionally 1-D.
Future multidimensional support can add tensor-product, block, or arbitrary
region partition objects without changing the QoI modules.

## Repository layout

```text
+pqoi/                       Public MATLAB package
  +qoi/+ks/                  KS QoI definitions
  +qoi/+channel/             Minimal-channel QoI definitions
  private/                   Internal array and interpolation helpers
examples/                    Runnable KS and channel examples
tests/                       Unit and legacy-regression tests
run_tests.m                  Test-suite entry point
```

## Development guidance

When extending the library:

1. Keep governing-equation formulas in a QoI or adapter module.
2. Keep partition geometry and numerical integration in the core.
3. Define boundaries in physical coordinates, even when initially selected
   by grid index.
4. Add a focused unit test and, when replacing established analysis code, a
   regression test against that implementation.
5. Do not commit large DNS or LES datasets. Use compact synthetic fixtures
   or documented external datasets.

The examples provide the shortest entry points for new applications:
`examples/ks_example.m` and `examples/channel_example.m`.
