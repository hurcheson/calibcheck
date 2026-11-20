# calibcheck (0.1.0 release candidate)

Independent audit for normalized calibration weights from arbitrary estimators.
This is not a new raking method. It asks three distinct questions: can any
nonnegative normalized weights attain the targets, did the supplied raw weights
attain them, and did post-processing change balance? Solver convergence is
metadata, not a certificate. Zero individual weights are not inherently a failure.

## Installation

This is development source for the 0.1.0 candidate, not a CRAN release.

```r
# install.packages("remotes")
remotes::install_github("hurcheson/calibcheck")
library(calibcheck)
```

## Quick start

```r
library(calibcheck)
M <- rbind(c(1,0),c(0,1),c(1,0),c(0,1))
a <- audit_calibration(M, c(.9,.1,.1,.9), c(.1,.9), c(.18,.82), TRUE,
                       target_num=c(9,1,1,9),target_den=10)
a$feasibility[c("status", "lower", "upper")]
a$raw$ledger
a$feasibility$certificate[c("lower_num","lower_den","upper_num","upper_den")]
```

Expected: minimum max residual 0.4, achieved raw 0.8, final 0.72;
the rational example automatically verifies the bounds. The numerical upper
witness lives on unique support patterns; the exact certificate contains
expanded original-column integer weights. Explicit rational counts determine
the exact target. Small dyadic targets are recognized automatically.

`check_feasibility(M, target, lower=0, upper=1)` works even when no producer
returns weights. Bounds are normalized per-task fractions, not mean-one weights.
`min_max_weight` estimates the smallest maximum individual weight at optimal
margin discrepancy, including bounded problems; `NA` means not evaluated or
not numerically verified (including a ten-second concentration-solver timeout).
Supplied raw/final weights have separate balance and box-violation diagnostics.

`calibration_matrix()` constructs labelled rows from categorical data and named
target fractions, retaining unobserved levels. Without labels, arbitrary binary
rows cannot reliably be grouped into complete margins; no total warning is inferred.

## Run

From the parent directory: `R CMD INSTALL calibcheck` then
`Rscript calibcheck/tests/regression.R`. Build then use `R CMD check --as-cran --no-manual calibcheck_0.1.0.tar.gz`
for package checks. For SciPy parity, run
`python calibcheck/validation/make_parity.py > parity.R`, then source the R
implementation and `parity.R`. Source `validation/state_example.R` for a small
nonbiological empirical illustration; the sampling restriction is deliberate.

Report reproducible issues via the repository's issue tracker. The vignette
describes the complete workflow and the limitations of exact certificates.

## Scope and limitations

- A binary cell matrix and explicit target fractions with optional closed box
  constraints. Arbitrary continuous rows, strictly positive open domains, and
  a distance-to-base-weight optimization objective are outside scope.
- Floating-point LP bounds are numerical. Exact verification is automatic for
  eligible unrestricted rational targets, but limited by the original integer
  cap; no arbitrary precision or exact bounded certificate. The tolerance is
  compared to the explicit round-tripping decimal when that fraction fits.
- Missing rows are reported individually; their mass must not be added across
  overlapping margins. ESS is descriptive and not a variance estimator.
- Different packages use different residual scales/tolerances, so no-status
  outputs are not evidence of a general package defect.
- MIT licensed. Maintainer: Hurcheson Ofori. This is a release candidate, not yet on CRAN.
- Public examples and tests use synthetic or built-in R data.
