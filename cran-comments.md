# CRAN submission preparation

Initial submission candidate, version 0.1.0. Not submitted.

## Test environments

On candidate f1f671e, [GitHub Actions](https://github.com/hurcheson/calibcheck/actions/runs/44698201099) reported Status OK (0 errors, 0 warnings, 0 notes) in all six R checks:

- Ubuntu 22.04 / R 4.1.2; coverage 95.05%.
- Ubuntu 24.04 / R 4.3.3; coverage 95.50%.
- Ubuntu 26.04 / R 4.6.2 and R-devel (2026-11-19 r90939).
- Windows Server 2022 / R 4.6.2.
- macOS / R 4.6.2.

All four current-R jobs reported 243 passing test expectations with no failures, warnings or skips. Both legacy jobs passed the 20 bounded-residual and 20 concentration oracle cases. These checks omitted the PDF manual; remote incoming checks were not actually run by the current-R helper action, so a new CI configuration explicitly enables incoming and remote checks and builds the PDF manual. Final results are pending.

## Remaining pre-submission evidence

Independent win-builder (release and devel) and mac-builder results, final source tarball and full incoming check results, and maintainer confirmation of redistribution rights and correspondence details.

## Notes

The package audits calibration feasibility independently of weight estimation. Synthetic fixtures and built-in R examples are distributed; no third-party archive data are included. Numerical bounded diagnostics are not exact certificates.
