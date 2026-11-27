# CRAN submission comments

Initial submission of calibcheck 0.1.0.

## Test environments

- Official Win-builder: Windows Server 2022, R 4.6.2 and R-devel (2026-11-17 r90926), both using the submission tarball: 0 errors, 0 warnings, 1 NOTE each.
- GitHub Actions: Linux (R 4.1.2, 4.3.3, 4.6.2 and R-devel), Windows and macOS (R 4.6.2): all passed. Current-R checks reported only the new-submission NOTE.
- Independent full local check of the submission tarball: 0 errors, 0 warnings, 2 NOTEs (new submission and inability to verify system time).

## R CMD check results

The only NOTE on both official Windows builders is "New submission". All tests and manuals passed. The independent local clock NOTE is environmental; the official Windows timestamp checks passed.

The external MacBuilder submission service was unavailable (official status report dated 2026-11-26); the GitHub Actions macOS R-release check passed.

The package audits calibration feasibility independently of weight estimation. Only synthetic fixtures and built-in R examples are distributed.
