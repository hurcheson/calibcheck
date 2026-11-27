# calibcheck

Can your data support the calibration targets you chose? calibcheck audits
normalized weights from any estimator. It measures the smallest attainable margin
error and compares it with the error in your supplied weights, before and after
post-processing.

## Installation

Install the [0.1.0 GitHub release](https://github.com/hurcheson/calibcheck/releases/tag/v0.1.0):

```r
# install.packages("remotes")
remotes::install_github("hurcheson/calibcheck@v0.1.0")
library(calibcheck)
```

## Quick start

Suppose two tasks represent two groups. The first and third cells contain
exactly the same task, yet their targets are 90% and 10%. Both cells must
receive the same weight. How close can any weighting get?

```r
M <- rbind(c(1, 0), c(0, 1), c(1, 0), c(0, 1))
target <- c(.9, .1, .1, .9)

# Check whether the targets can be reached, even without fitted weights.
fit <- check_feasibility(M, target)
fit[c("status", "lower", "upper")]

# Audit the weights supplied by an estimator and its post-processing step.
audit <- audit_calibration(
  M = M, target = target, raw = c(.1, .9), final = c(.18, .82),
  converged = TRUE, target_num = c(9, 1, 1, 9), target_den = 10
)
audit$raw$ledger
audit$final$ledger
```

Even the best weights miss at least one target by **40 percentage points**.
Splitting the weight equally attains that bound. The supplied weights miss
by **80 points**, and post-processing reduces the largest miss to **72 points**.
The estimator reported convergence in this example.

Follow the [worked example](https://hurcheson.github.io/calibcheck/articles/calibcheck.html)
to interpret the ledger and inspect the exact certificate.

## Working with your data

`check_feasibility(M, target, lower=0, upper=1)` works even when no producer
returns weights. Bounds are normalized per-task fractions, not mean-one weights.
`min_max_weight` estimates the smallest maximum individual weight at optimal
margin discrepancy, including bounded problems; `NA` means not evaluated or
not numerically verified (including a ten-second concentration-solver timeout).
For large bounded problems, the additional LP can take several seconds. Set
`concentration = FALSE` in either audit function to skip it without changing
feasibility or balance diagnostics. Supplied raw/final weights have separate balance and box-violation diagnostics.

`calibration_matrix()` constructs labelled rows from categorical data and named
target fractions, retaining unobserved levels. Without labels, arbitrary binary
rows cannot reliably be grouped into complete margins; no total warning is inferred.

## Scope and limitations

- A binary cell matrix and explicit target fractions with optional closed box
  constraints. Arbitrary continuous rows, strictly positive open domains, and
  a distance-to-base-weight optimization objective are outside scope.
- Floating-point LP bounds are numerical. Exact verification is automatic for
  eligible unrestricted rational targets, but limited by the original integer
  cap; no arbitrary precision or exact bounded certificate. The tolerance is
  compared to the explicit round-tripping decimal when that fraction fits (e.g. `2^-30` does not fit).
  An exactly zero upper certificate remains decisive.
- Missing rows are reported individually; their mass must not be added across
  overlapping margins. ESS is descriptive and not a variance estimator.
- Different packages use different residual scales/tolerances, so no-status
  outputs are not evidence of a general package defect.
- MIT licensed. Maintainer: Hurcheson Asante Ofori.
- Public examples and tests use synthetic or built-in R data.
