\name{verify_certificate}
\alias{verify_certificate}
\title{Verify a rational primal-dual certificate}
\usage{verify_certificate(M, target_num, target_den, weight_num, dual_num, dual_den)}
\arguments{
\item{M}{Numeric binary matrix.}
\item{target_num}{Integer target numerators, one per row.}
\item{target_den}{Positive common integer target denominator.}
\item{weight_num}{Nonnegative integer weights; their sum is the denominator.}
\item{dual_num}{Signed integer dual numerators, one per row.}
\item{dual_den}{Positive common integer dual denominator.}
}
\description{Checks simplex and dual feasibility and evaluates the exact
integer numerators and denominators of a residual sandwich.}
\details{All intermediate integer operations are conservatively bounded
below 2^50 so binary64 arithmetic can represent them exactly. Unsupported
large inputs are rejected. The certificate is for the specified rational
targets, not an unknown unrounded version. Exact comparisons of rational
bounds should use cross multiplication only when products stay in range.}
\value{A list containing lower_num, lower_den, upper_num, upper_den and exact.}
\examples{verify_certificate(diag(2),c(3,3),10,c(1,1),c(-1,-1),2)}
