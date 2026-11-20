# CRAN submission preparation (draft)

Initial submission candidate, version 0.1.0. Not submitted.

## Test environments

- Earlier public candidate (515cd6e): Ubuntu 22.04 / R 4.1.2 and Ubuntu 24.04 / R 4.3.3, Status OK with remote incoming and clock checks disabled and no manual. Coverage 91.82% and 92.27%.
- Current release and R-devel on Linux, Windows and macOS: configured in CI; results pending on the revised candidate.
- win-builder, mac-builder, final manual and CRAN incoming checks: record actual results before submission.

## Notes

The package audits calibration feasibility independently of weight estimation. Synthetic fixtures and built-in R examples are distributed; no third-party archive data are included. Numerical bounded diagnostics are not exact certificates. The maintainer must review the final tarball and confirm redistribution rights and correspondence details before submission.
