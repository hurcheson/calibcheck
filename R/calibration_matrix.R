#' Construct binary calibration rows from categorical data.
calibration_matrix <- function(data, targets) {
  if (!is.data.frame(data) || nrow(data) == 0L || !is.list(targets) ||
      !length(targets) || is.null(names(targets)) || anyNA(names(targets)) ||
      any(names(targets) == "") || anyDuplicated(names(targets)) ||
      !all(names(targets) %in% names(data))) stop("Invalid data or named target list")
  rows <- list()
  for (nm in names(targets)) {
    values <- as.character(data[[nm]])
    p <- targets[[nm]]
    lev <- names(p)
    if (is.null(lev) || anyNA(lev) || any(lev == "") || anyDuplicated(lev))
      stop("Target levels must be unique and named")
    p <- validate_target(p, length(lev))
    if (anyNA(values) || !all(values %in% lev)) stop("Unknown or missing observed level in ", nm)
    if (abs(sum(p) - 1) > 1e-12) warning("Target totals inconsistent for margin ", nm, call. = FALSE)
    rows[[nm]] <- list(M = t(outer(values, lev, `==`)) * 1,
                       target = unname(p), margin = rep(nm, length(lev)), level = lev)
  }
  list(M = do.call(rbind, lapply(rows, `[[`, "M")),
       target = unlist(lapply(rows, `[[`, "target"), use.names = FALSE),
       margin = unlist(lapply(rows, `[[`, "margin"), use.names = FALSE),
       level = unlist(lapply(rows, `[[`, "level"), use.names = FALSE))
}
