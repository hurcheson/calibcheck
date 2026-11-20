# Numerical LP and separately verified rational certificates.
fraction_cmp <- function(a,b,c,d) {
  # Continued-fraction comparison avoids cross-product overflow. Inputs are
  # nonnegative integers below 2^50, positive denominators.
  sign <- 1
  repeat {
    q <- floor(a/b); r <- floor(c/d)
    if (q!=r) return(sign*base::sign(q-r))
    x <- a-q*b; z <- c-r*d
    if (x==0 || z==0) return(sign*base::sign(x-z))
    a <- b; b <- x; c <- d; d <- z; sign <- -sign
  }
}

# lpSolve accepts constraint triplets, avoiding m-by-m dense identity blocks.
sparse_lp <- function(direction, objective, C, dir, rhs, extra=NULL, timeout=0L) {
  ij <- which(C!=0,arr.ind=TRUE)
  trip <- cbind(ij[,1],ij[,2],C[ij])
  if(!is.null(extra)) trip <- rbind(trip,extra)
  used <- sort(unique(trip[,1])); missing <- setdiff(seq_along(dir),used)
  if(length(missing)) {
    ok <- (dir[missing]=="<=" & rhs[missing]>=0) | (dir[missing]==">=" & rhs[missing]<=0) |
      (dir[missing]=="=" & rhs[missing]==0)
    if(!all(ok)) return(list(status=2L))
    trip[,1] <- match(trip[,1],used);dir <- dir[used];rhs <- rhs[used]
  }
  trip <- trip[order(trip[,1],trip[,2]),,drop=FALSE]
  args <- list(direction=direction,objective.in=objective,const.dir=dir,const.rhs=rhs,dense.const=trip)
  if("timeout" %in% names(formals(lpSolve::lp))) args$timeout <- timeout
  else if(timeout>0 && length(objective)>5000) return(list(status=NA_integer_))
  do.call(lpSolve::lp,args)
}

tolerance_fraction <- function(tol) {
  s <- format(tol, scientific=FALSE, digits=15, trim=TRUE)
  p <- strsplit(s,".",fixed=TRUE)[[1]]
  d <- if(length(p)==2) 10^nchar(p[2]) else 1
  a <- round(tol*d)
  if(!is.finite(d) || d>2^50 || a>2^50 || a/d!=tol) return(NULL)
  c(a,d)
}

#' Construct and verify rational witnesses from an unrestricted feasibility result.
rationalize_certificate <- function(M, target_num, target_den, feasibility, tolerance=1e-6) {
  M <- validate_matrix(M)
  if (!identical(feasibility$scope,"unrestricted_simplex") || is.null(feasibility$weight_witness))
    stop("An unrestricted solved feasibility result is required")
  if(length(target_den)!=1 || !is.finite(target_den) || target_den<=0 || target_den!=trunc(target_den))
    stop("Invalid target denominator")
  if(length(target_num)!=nrow(M) || any(!is.finite(target_num)) || any(target_num!=trunc(target_num)) ||
     any(target_num<0 | target_num>target_den)) stop("Invalid target numerators")
  max_scale <- floor(min(2^50/(4*target_den),2^50/ncol(M),2^50/nrow(M)))
  if(max_scale<1) return(NULL)
  scales <- unique(pmin(c(2^20,2^31,max_scale),max_scale))
  tf <- tolerance_fraction(tolerance); best <- NULL
  for (scale in scales) {
    w <- feasibility$weight_witness; y <- feasibility$dual_witness
    # Largest remainder rounding retains a positive total and exact simplex.
    z <- w*scale; num <- floor(z); left <- round(scale-sum(num))
    if(left>0 && left<=length(num)) num[order(z-num,decreasing=TRUE)[seq_len(left)]] <-
      num[order(z-num,decreasing=TRUE)[seq_len(left)]]+1
    if(sum(num)!=scale) next
    full <- numeric(ncol(M)); full[feasibility$pattern_indices] <- num
    yn <- round(y*scale); dy <- max(scale,sum(abs(yn)))
    v <- tryCatch(verify_certificate(M,target_num,target_den,full,yn,dy),error=function(e) NULL)
    if(is.null(v)) next
    v$lower <- v$lower_num/v$lower_den; v$upper <- v$upper_num/v$upper_den
    v$weight_num <- full; v$dual_num <- yn; v$dual_den <- dy; v$resolution <- scale
    v$target_num <- target_num; v$target_den <- target_den; v$status <- "numerically_ambiguous"
    if(v$upper_num == 0) v$status <- "attainable_to_tolerance"
    else if(!is.null(tf)) {
      if(fraction_cmp(v$lower_num,v$lower_den,tf[1],tf[2])>0) v$status <- "infeasible_to_tolerance"
      else if(fraction_cmp(v$upper_num,v$upper_den,tf[1],tf[2])<=0) v$status <- "attainable_to_tolerance"
    }
    best <- v
    if(v$status!="numerically_ambiguous") break
  }
  best
}

#' Feasibility of target margins independently of producer weights.
check_feasibility <- function(M,target,tolerance=1e-6,lower=0,upper=1,
                              target_num=NULL,target_den=NULL) {
  M <- validate_matrix(M); k <- nrow(M); n <- ncol(M)
  target <- validate_target(target, k)
  if(!is.numeric(tolerance)||length(tolerance)!=1||!is.finite(tolerance)||tolerance<=0) stop("Invalid tolerance")
  bounds <- function(x) {
    if(!is.numeric(x)||!length(x)%in%c(1,n)||any(!is.finite(x))||any(x<0|x>1)) stop("Invalid weight bounds")
    rep_len(x,n)
  }
  lo <- bounds(lower); hi <- bounds(upper)
  if(any(lo>hi)) stop("Lower bound exceeds upper bound")
  bounded <- any(lo!=0|hi!=1); scope <- if(bounded) "bounded_simplex" else "unrestricted_simplex"
  f <- list(status="solver_failed",scope=scope,lower=NA_real_,upper=NA_real_,exact=FALSE)
  if(sum(lo)>1 || sum(hi)<1) {f$status <- "empty_weight_domain"; return(f)}
  if(xor(is.null(target_num),is.null(target_den))) stop("Provide both target_num and target_den")
  if(!is.null(target_num)) {
    if(!is.numeric(target_num)||length(target_num)!=k||any(!is.finite(target_num))||any(target_num!=trunc(target_num))||
       length(target_den)!=1||!is.numeric(target_den)||!is.finite(target_den)||target_den<=0||target_den!=trunc(target_den)||
       any(target_num<0|target_num>target_den)||any(target_num/target_den!=target)) stop("Rational targets must match target")
  }
  keep <- !duplicated(t(M)); A <- M[,keep,drop=FALSE]; m <- ncol(A)
  # Group all identical columns. Group IDs from a binary-pattern string.
  keys <- apply(M,2,paste0,collapse=""); group <- match(keys,keys[keep]); count <- tabulate(group,m)
  l <- as.numeric(rowsum(lo,group,reorder=TRUE)); u <- pmin(1,as.numeric(rowsum(hi,group,reorder=TRUE)))
  C <- rbind(cbind(A,-1),cbind(-A,-1),c(rep(1,m),0))
  dir <- c(rep("<=",2*k),"="); rhs <- c(target,-target,1)
  if(bounded){j <- seq_len(m);extra <- rbind(cbind(2*k+1+j,j,1),cbind(2*k+1+m+j,j,1));dir <- c(dir,rep(c(">=","<="),each=m));rhs <- c(rhs,l,u)
    p <- sparse_lp("min",c(rep(0,m),1),C,dir,rhs,extra)
  } else p <- lpSolve::lp("min",c(rep(0,m),1),C,dir,rhs)
  f$primal_status <- p$status; f$pattern_indices <- which(keep); f$pattern_counts <- count
  if(p$status!=0) return(f)
  w <- pmin(u,pmax(l,p$solution[seq_len(m)])); delta <- 1-sum(w)
  # Repair within box: distribute remaining mass over available slack.
  if(delta>0) {slack <- u-w; if(sum(slack)>0) w <- w+delta*slack/sum(slack)}
  if(delta<0) {slack <- w-l; if(sum(slack)>0) w <- w+delta*slack/sum(slack)}
  if(!bounded) w <- w/sum(w)
  # Box support function via LP dual variables for upper-cap constraints.
  if(!bounded) {
    d <- lpSolve::lp("max",c(target,-target,-1,1),
      rbind(cbind(t(A),-t(A),-1,1),c(rep(1,2*k),0,0)),rep("<=",m+1),c(rep(0,m),1))
  } else {
    v <- target-drop(A%*%l); s <- 1-sum(l)
    d <- sparse_lp("max",c(v,-v,-s,s,-(u-l)),
      rbind(cbind(t(A),-t(A),-1,1),c(rep(1,2*k),0,0)),
      rep("<=",m+1),c(rep(0,m),1),cbind(seq_len(m),2*k+2+seq_len(m),-1))
  }
  f$dual_status <- d$status
  if(d$status!=0) return(f)
  y <- d$solution[seq_len(k)]-d$solution[k+seq_len(k)]; y <- y/max(1,sum(abs(y)))
  score <- drop(crossprod(A,y)); support <- sum(l*score); remaining <- 1-sum(l)
  for(j in order(score,decreasing=TRUE)){add <- min(remaining,u[j]-l[j]);support <- support+add*score[j];remaining <- remaining-add;if(remaining<=0) break}
  lb <- max(0,sum(target*y)-support); ub <- max(abs(drop(A%*%w)-target))
  guard <- max(1e-12,16*.Machine$double.eps*max(k,m))
  f$status <- "numerically_ambiguous"; f$lower <- lb; f$upper <- ub; f$gap <- ub-lb
  f$weight_witness <- w; f$dual_witness <- y; f$comparison_guard <- guard
  if(lb<=ub+guard) {
    if(lb>tolerance+guard) f$status <- "infeasible_to_tolerance"
    else if(ub<=tolerance-guard || (ub==0 && lb==0)) f$status <- "attainable_to_tolerance"
  }
  f$numerical_status <- f$status
  # Ask for exact rational proof automatically when the target is explicit or
  # a small exactly representable dyadic fraction. Never silently round targets.
  if(!bounded && is.null(target_num)) for(D in 2^(0:30)) {
    if(all(target*D==trunc(target*D))) {target_num <- target*D;target_den <- D;break}
  }
  if(!bounded && !is.null(target_num)) {
    f$certificate <- rationalize_certificate(M,target_num,target_den,f,tolerance)
    if(!is.null(f$certificate) && f$certificate$status!="numerically_ambiguous") {
      f$status <- f$certificate$status;f$exact <- TRUE
    }
  }
  # Minimise maximum individual weight at the attained optimal residual.
  # For an unrestricted group, equal splitting is optimal. With heterogeneous
  # bounds use the original columns and individual caps, not group averages.
  f$min_max_weight <- NA_real_
  if(!bounded) {
    j <- seq_len(m)
    Q <- sparse_lp("min",c(rep(0,m),1),rbind(cbind(A,0),cbind(-A,0),c(rep(1,m),0)),
      c(rep("<=",2*k),"=",rep("<=",m)),c(target+ub,-target+ub,1,rep(0,m)),
      rbind(cbind(2*k+1+j,j,1),cbind(2*k+1+j,m+1,-count)),timeout=10L)
    f$concentration_status <- Q$status
    if(isTRUE(Q$status==0)) {
      q <- Q$solution[seq_len(m)]; cap <- Q$solution[m+1]
      if(all(q>=-guard) && abs(sum(q)-1)<=guard && max(q/count)<=cap+guard &&
         max(abs(drop(A%*%q)-target))<=ub+guard) f$min_max_weight <- cap
    }
  } else {
    j <- seq_len(n)
    Q <- sparse_lp("min", c(rep(0,n),1),
      rbind(cbind(M,0),cbind(-M,0),c(rep(1,n),0)),
      c(rep("<=",2*k),"=",rep(c(">=","<=","<="),each=n)),
      c(target+ub,-target+ub,1,lo,hi,rep(0,n)),
      rbind(cbind(2*k+1+j,j,1), cbind(2*k+1+n+j,j,1),
            cbind(2*k+1+2*n+j,j,1), cbind(2*k+1+2*n+j,n+1,-1)), timeout=10L)
    f$concentration_status <- Q$status
    if(isTRUE(Q$status==0)) {
      q <- Q$solution[seq_len(n)]; cap <- Q$solution[n+1]
      if(all(q>=lo-guard) && all(q<=hi+guard) && abs(sum(q)-1)<=guard &&
         max(q)<=cap+guard && max(abs(drop(M%*%q)-target))<=ub+guard)
        f$min_max_weight <- cap
    }
  }
  f
}
