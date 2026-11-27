# Contributing

Please report issues with a minimal reproducible example, package and R version,
expected result, actual result and (where relevant) explicit rational targets.
Do not include sensitive data; use synthetic inputs. Contributions should include
value-based tests and updated documentation. The maintainer reviews all changes.

## Validate a source checkout

From the parent directory: `R CMD INSTALL calibcheck` then
`Rscript calibcheck/tests/regression.R`. Build then use `R CMD check --as-cran --no-manual calibcheck_0.1.0.tar.gz`
for package checks. For SciPy parity, run
`python calibcheck/validation/make_parity.py > parity.R`, then source the R
implementation and `parity.R`. Source `validation/state_example.R` for a small
nonbiological empirical illustration; the sampling restriction is deliberate.
