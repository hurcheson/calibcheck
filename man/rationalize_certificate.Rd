\name{rationalize_certificate}
\alias{rationalize_certificate}
\title{Automatically construct an exact rational certificate}
\usage{rationalize_certificate(M, target_num, target_den, feasibility,
  tolerance = 1e-6)}
\arguments{
\item{M}{Original binary matrix.}
\item{target_num,target_den}{Explicit integer target numerators and common denominator.}
\item{feasibility}{Solved unrestricted result from check_feasibility.}
\item{tolerance}{Positive tolerance, interpreted as its round-tripping decimal when representable within the integer cap.}
}
\description{Rounds numerical witnesses at increasing safe resolutions,
expands pattern weights to original columns, and calls the exact verifier.}
\details{The exact certificate applies to the rational target supplied, not an
unknown population proportion. Integer products are bounded by the existing
2^50 guard. If the required denominator is too large, no certificate is
returned; arbitrary precision is not implemented. Resolution starts at
2^20, then 2^31, then the largest conservative safe integer if needed.
If the tolerance cannot be represented by a round-tripping decimal within the integer cap (for example, 2^-30), a nonzero certificate bracket remains undecided; an exactly zero upper bound is decisive for any positive tolerance.
Numerical ambiguity is not solver failure.}
\value{An exact rational bracket with explicit integer witnesses and certificate status, or NULL if no safe witness can be constructed.}
\examples{M <- diag(2); f <- check_feasibility(M,c(.5,.5)); rationalize_certificate(M,c(1,1),2,f)}
