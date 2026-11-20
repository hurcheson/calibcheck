\name{check_feasibility}
\alias{check_feasibility}
\title{Check calibration feasibility independently of supplied weights}
\usage{check_feasibility(M, target, tolerance = 1e-6, lower = 0, upper = 1,
  target_num = NULL, target_den = NULL, concentration = TRUE)}
\arguments{
\item{M}{Binary numeric or logical matrix, one row per cell and column per task.}
\item{target}{Numeric target fractions. Values just above one within two machine epsilons are corrected with a warning; larger excursions are rejected.}
\item{tolerance}{Positive absolute tolerance, inclusive at the boundary.}
\item{lower,upper}{Normalized per-task box bounds, scalar or vector.}
\item{concentration}{Logical; compute the optional minimum maximum-weight diagnostic. Set FALSE to skip this additional LP.}
\item{target_num,target_den}{Optional exact integer target counts and common denominator matching target.}
}
\description{Computes the minimum maximum absolute target margin discrepancy on the specified weight domain.}
\details{Duplicate support patterns are aggregated, including their summed
box bounds. The numerical primal and signed-dual estimates are separate from
any exact rational certificate. Status is attainable_to_tolerance,
infeasible_to_tolerance, numerically_ambiguous, solver_failed, or
empty_weight_domain. The last status refers to the box itself. The guard band
does not constitute a rigorous floating-point error bound. For unrestricted
problems with exact rational targets, the verifier attempts an exact decision.
Bounded results are numerical only. The min_max_weight diagnostic estimates
the minimum largest individual task weight at the numerically achieved
optimal margin discrepancy. Unrestricted patterns are split equally; bounded
problems use individual caps. An unavailable, skipped, or unverified result is NA. Large bounded problems can take several seconds; the solver is requested to time out after ten seconds when supported.}
\value{A list with status, scope, numerical bounds, witnesses, certificate
when available, and numerical concentration diagnostic.}
\examples{check_feasibility(matrix(c(1,0,0,0),1),.97,upper=.5)}
