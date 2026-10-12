# Datasets

This directory contains compact time-averaged profiles for the examples,
tests, and method-development workflows. Raw time histories and simulation
restart files are intentionally excluded.

## KS profiles

`ks/dirichlet_profiles.mat` and `ks/periodic_profiles.mat` each provide:

- A 2049-point DNS profile
- 129-, 257-, and 513-point LES profiles
- Mean field, mean-square field, mean energy, fluctuating energy, and total
  energy profiles

Use `pqoi.io.loadKSProfiles` to convert the stored variables into the common
`coordinate`, `data`, and `profiles` structures.

## Minimal-channel profiles

The channel dataset contains time-averaged wall-normal profiles at friction
Reynolds number approximately 180. `minimal_channel/uniform` provides one
81-point DNS reference and LES profiles with 9, 17, 33, 65, and 129 uniformly
distributed wall-normal points.

File headers retain the averaging time, friction Reynolds number, friction
velocity, viscosity, wall shear, grid dimensions, and simulation step. The
DNS contains velocity means, second moments, Reynolds shear, velocity
gradient, and residual dissipation. Every LES file contains the full set of
velocity means and second moments, Reynolds and SGS shear, velocity gradient,
SGS viscosity, and dissipation diagnostics.

Use `pqoi.io.loadChannelProfile` to read either DNS or LES files. The loader
computes total shear stress, turbulent kinetic energy, and production from
each included DNS or LES profile.

## Data conventions

- Coordinates are stored in increasing order.
- KS energy profiles returned by the loader include the conventional factor
  of one half.
- Channel DNS files contain 10 profile columns. The uniform LES files contain
  13 columns, including velocity second moments and SGS quantities.
- Dataset files should remain small enough for ordinary Git. Large raw
  simulation outputs should be archived separately.
