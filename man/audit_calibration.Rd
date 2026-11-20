\name{audit_calibration}
\alias{audit_calibration}
\title{Audit normalized calibration weights}
\usage{audit_calibration(M, target, raw = NULL, final = NULL, converged = NA,
  tolerance = 1e-6, case_id = NULL, margin = NULL, level = NULL,
  lower = 0, upper = 1, target_num = NULL, target_den = NULL)}
\arguments{
\item{M}{Numeric or logical binary matrix with margin cells as rows and tasks as columns.}
\item{target}{Target fractions, one per row; roundoff just above one within two machine epsilons is corrected with a warning.}
\item{raw}{Optional nonnegative finite weights with positive finite sum.}
\item{final}{Optional post-processed weights in the same column order.}
\item{converged}{Optional logical upstream convergence flag; unknown is NA.}
\item{tolerance}{Positive absolute proportion-scale tolerance.}
\item{case_id}{Optional nonmissing case identifier for each task.}
\item{margin,level}{Optional row labels; a complete one-hot margin with inconsistent target total generates a warning.}
\item{lower,upper}{Normalized per-task box bounds for the feasibility model; scalar or one per column.}
\item{target_num,target_den}{Optional explicit integer target numerators and common denominator matching target.}
}
\description{Audits supplied weights independently of their estimator.}
\details{Feasibility is over the normalized simplex with optional box bounds.
LP witnesses are repaired and evaluated in floating point; the resulting numerical bounds are not exact certificates.
An unrestricted rational certificate is attempted when eligible targets are provided.
Near-threshold or unsuccessful solves remain unresolved. The raw and final
residuals are evaluated separately from the upstream convergence flag.}
\value{A list of feasibility diagnostics, unsupported margin rows and target
fractions, convergence flag, and raw and optional final summaries. Each summary
contains a residual ledger, task ESS and optional case-collapsed ESS.}
\examples{audit_calibration(rbind(c(1,0),c(0,1)),c(.8,.2),c(.8,.2))}
