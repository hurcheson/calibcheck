# CRAN submission comments

Initial submission candidate, version 0.1.0. Not submitted.

## Test environments

Tested package source at 6479d0f6c27bb7f872c4a178de100f1c4c73f71e (2026-11-20), [GitHub Actions run 44699974222](https://github.com/hurcheson/calibcheck/actions/runs/44699974222):

| Environment | R version | Result |
|---|---|---|
| Ubuntu 22.04 | 4.1.2 | Status OK |
| Ubuntu 24.04 | 4.3.3 | Status OK |
| Ubuntu 26.04 | 4.6.2 | 0 errors, 0 warnings, 1 NOTE |
| Ubuntu 26.04 | R-devel (2026-11-18 r90935) | 0 errors, 0 warnings, 1 NOTE |
| Windows Server 2022 | 4.6.2 | 0 errors, 0 warnings, 1 NOTE |
| macOS | 4.6.2 | 0 errors, 0 warnings, 1 NOTE |

The current-R checks explicitly enabled CRAN incoming and remote checks. The additional full Linux R-release `R CMD check --as-cran` enabled the clock check, validated both PDF and HTML manuals, and reported 0 errors, 0 warnings, 1 NOTE. The NOTE was "New submission", expected for a first submission.

All four current-R jobs reported 243 passing test expectations and zero failures, warnings or skips. Both legacy jobs passed 20 bounded-residual and 20 concentration oracle cases; coverage was 95.05% and 95.50%, respectively. Legacy checks disabled remote incoming and system clock checks and omitted the PDF manual. The spelling check reported no errors. [Package documentation](https://github.com/hurcheson/calibcheck/actions/runs/44699974236) built successfully.

## Checked source tarball

[`release-check-evidence`](https://github.com/hurcheson/calibcheck/actions/runs/44699974222/artifacts/14612278672) contains the source tarball, R check log and PDF manual. SHA-256 of `calibcheck_0.1.0.tar.gz`:

`a8c51706e43e60473c9b3dec471771c83a1af164340b42cf67d8514e8b7c502b`

## Remaining pre-submission items

- Independent win-builder and mac-builder results have not been obtained; the native GitHub Windows/macOS checks above are not those services.
- Maintainer review of the exact tarball, confirmation of redistribution rights and correspondence details, final independent review, and explicit submission authorization remain pending.

## Notes

The package audits calibration feasibility independently of weight estimation. Synthetic fixtures and built-in R examples are distributed; no third-party archive data are included. Numerical bounded diagnostics are not exact certificates. This file is excluded from the source tarball.
