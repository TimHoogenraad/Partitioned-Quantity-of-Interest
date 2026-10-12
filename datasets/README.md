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

The channel datasets contain time-averaged wall-normal profiles at friction
Reynolds number approximately 180:

- `minimal_channel/tke_adaptive`: grid adaptation targeting turbulent
  kinetic energy
- `minimal_channel/shear_adaptive`: grid adaptation targeting total shear
  stress

Each sequence contains one 81-point DNS reference and seven LES iterations.
The LES profile sizes increase from 9 to 33 points. File headers retain the
averaging time, friction Reynolds number, friction velocity, viscosity,
wall shear, grid dimensions, and simulation step. The tabulated columns
contain velocity means, second moments, Reynolds shear, velocity gradient,
SGS quantities, and dissipation diagnostics where applicable.

Use `pqoi.io.loadChannelProfile` to read either DNS or LES files. The loader
also computes total shear stress, turbulent kinetic energy, and production
profiles using the included channel QoI modules.

## Data conventions

- Coordinates are stored in increasing order.
- KS energy profiles returned by the loader include the conventional factor
  of one half.
- Channel DNS files contain 10 profile columns; LES files contain 13 and
  include SGS quantities.
- Dataset files should remain small enough for ordinary Git. Large raw
  simulation outputs should be archived separately.
