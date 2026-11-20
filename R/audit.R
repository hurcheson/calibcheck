# Independent auditor; no upstream implementation is copied.
validate_matrix <- function(M) {
  if (is.matrix(M) && is.logical(M)) storage.mode(M) <- "double"
  if (!is.matrix(M) || !is.numeric(M) || any(dim(M)==0) ||
      any(!is.finite(M)) || any(!M %in% c(0,1))) stop("M must be a nonempty binary matrix")
  M
}

validate_target <- function(target, k) {
  eps <- 2 * .Machine$double.eps
  if (!is.numeric(target) || length(target) != k || any(!is.finite(target)) ||
      any(target < 0 | target > 1 + eps)) stop("Invalid target fractions")
  if (any(target > 1)) {
    warning("Target roundoff just above one corrected to one", call. = FALSE)
    target <- pmin(target, 1)
  }
  target
}

normalize_weights <- function(w, n) {
  if (!is.numeric(w) || length(w)!=n || any(!is.finite(w)) || any(w<0) ||
      !is.finite(sum(w)) || sum(w)<=0) stop("Invalid weights")
  w/sum(w)
}

#' Audit normalized calibration weights
audit_calibration <- function(M, target, raw=NULL, final=NULL, converged=NA, tolerance=1e-6,
                              case_id=NULL, margin=NULL, level=NULL, lower=0, upper=1,
                              target_num=NULL,target_den=NULL) {
  M <- validate_matrix(M); k <- nrow(M); n <- ncol(M)
  target <- validate_target(target, k)
  if (!is.numeric(tolerance) || length(tolerance)!=1 || !is.finite(tolerance) || tolerance<=0)
    stop("Invalid tolerance")
  if (!is.logical(converged) || length(converged)!=1) stop("Invalid convergence flag")
  if (!is.null(case_id) && (length(case_id)!=n || anyNA(case_id))) stop("Invalid case IDs")
  if(!is.null(margin) && (length(margin)!=k || anyNA(margin))) stop("Invalid margin labels")
  if(!is.null(level) && (length(level)!=k || anyNA(level))) stop("Invalid level labels")
  if(!is.null(margin)) for(idx in split(seq_len(k),margin)) {
    if(all(colSums(M[idx,,drop=FALSE])==1) && abs(sum(target[idx])-1)>1e-12)
      warning("Target totals inconsistent for margin ",margin[idx[1]],call.=FALSE)
  }
  if(is.null(margin)) margin <- rep(NA_character_,k)
  if(is.null(level)) level <- if(is.null(rownames(M))) as.character(seq_len(k)) else rownames(M)
  f <- check_feasibility(M,target,tolerance,lower,upper,target_num,target_den)
  summarize <- function(w) {
    p <- normalize_weights(w,n); achieved <- drop(M %*% p)
    residual <- achieved-target; gap <- max(abs(residual))
    bound_gap <- max(0,rep_len(lower,n)-p,p-rep_len(upper,n))
    case_ess <- if (is.null(case_id)) NULL else 1/sum(rowsum(p,case_id)^2)
    list(gap=gap, balanced=gap<=tolerance, within_weight_bounds=bound_gap<=16*.Machine$double.eps,
         bound_violation=bound_gap, task_ess=1/sum(p^2), case_ess=case_ess,
         zero_weights=sum(w==0), input_total=sum(w),
         ledger=data.frame(margin=margin,level=level,target=target, achieved=achieved, residual=residual))
  }
  raw_summary <- if(is.null(raw)) NULL else summarize(raw); final_summary <- if (is.null(final)) NULL else summarize(final)
  unsupported <- which(rowSums(M)==0 & target>0)
  list(feasibility=f,numerical_converged=converged,tolerance=tolerance,
       unsupported_rows=unsupported,unsupported_target=target[unsupported],
       raw=raw_summary,final=final_summary)
}

#' Verify a rational certificate using exactly representable integer arithmetic
#' All numerators and denominators are integers, and all intermediate integer
#' operations are bounded below 2^50. Larger inputs are rejected, not rounded.
verify_certificate <- function(M, target_num, target_den, weight_num, dual_num, dual_den) {
  M <- validate_matrix(M); k <- nrow(M); n <- ncol(M); cap <- 2^50
  whole <- function(x, len) is.numeric(x) && length(x)==len &&
    all(is.finite(x)) && all(abs(x)<=cap) && all(x==trunc(x))
  if (!whole(target_den,1) || target_den<=0 || !whole(dual_den,1) || dual_den<=0 ||
      !whole(target_num,k) || any(target_num<0 | target_num>target_den) ||
      !whole(weight_num,n) || any(weight_num<0) || !whole(dual_num,k)) stop("Invalid rational inputs")
  # Bound sums before computing them; conservative rejection prevents rounding.
  if (max(weight_num)>cap/n || max(abs(dual_num))>cap/k) stop("Integer range exceeded")
  W <- sum(weight_num); Y <- sum(abs(dual_num))
  if (W<=0 || Y>dual_den) stop("Invalid simplex/dual witness")
  if (W>cap/(4*target_den) || dual_den>cap/(4*target_den)) stop("Integer range exceeded")
  # Coerce integer vectors to double before multiplication (avoid R int overflow).
  target_num <- as.numeric(target_num); weight_num <- as.numeric(weight_num)
  dual_num <- as.numeric(dual_num); target_den <- as.numeric(target_den); dual_den <- as.numeric(dual_den)
  L <- max(0,sum(target_num*dual_num)-target_den*max(drop(crossprod(M,dual_num))))
  U <- max(abs(target_den*drop(M %*% weight_num)-W*target_num))
  list(lower_num=L,lower_den=target_den*dual_den,upper_num=U,upper_den=target_den*W,
       exact=TRUE)
}
