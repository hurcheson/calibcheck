\name{calibration_matrix}
\alias{calibration_matrix}
\title{Construct calibration rows from categorical data}
\usage{calibration_matrix(data, targets)}
\arguments{
\item{data}{Nonempty data frame with categorical columns. Values are converted to character labels.}
\item{targets}{Named list of named numeric target fractions. List names match data columns and vector names specify their levels.}
}
\description{Builds a binary cell-by-task matrix and aligned target and label vectors, including unobserved target levels.}
\details{Unknown or missing observed values are rejected. A complete margin whose target total differs from one by more than 1e-12 generates a warning, not an automatic renormalization.}
\value{List containing M, target, margin and level.}
\examples{
z <- calibration_matrix(data.frame(region = c("a", "a", "b")),
                        list(region = c(a = .5, b = .25, c = .25)))
check_feasibility(z$M, z$target)
}
