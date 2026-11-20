# calibcheck 0.1.0

Initial release.

* Added categorical data-frame conversion with explicit margin and level labels.
* Added numerical minimum maximum-weight diagnostics for heterogeneous box constraints, with an option to skip the extra LP.
* Accept logical binary matrices and warn before correcting tiny upper-end target roundoff.
* Expand exact certificate boundary and retry tests; an exactly zero residual certificate is decisive for every positive tolerance.
* Provide MIT licensing, persistent maintainer contact, documentation, and reproducible examples.
