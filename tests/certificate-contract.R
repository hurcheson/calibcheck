if (Sys.getenv("CALIBCHECK_SOURCE") != "") {
  source(Sys.getenv("CALIBCHECK_SOURCE"))
  source(Sys.getenv("CALIBCHECK_FEASIBILITY_SOURCE"))
} else library(calibcheck)

M <- rbind(c(1,0),c(0,1),c(1,0),c(0,1))
a <- check_feasibility(M, c(.9,.1,.1,.9), target_num=c(9,1,1,9), target_den=10)
stopifnot(a$status=="infeasible_to_tolerance", a$certificate$exact,
          abs(a$certificate$lower-.4)<1e-7)
b <- check_feasibility(M, c(.75,.25,.25,.75), tolerance=.25,
                       target_num=c(3,1,1,3),target_den=4)
stopifnot(b$status=="attainable_to_tolerance", b$certificate$exact)
c <- check_feasibility(diag(2), c(.5,.5), tolerance=1e-14)
stopifnot(c$status=="attainable_to_tolerance")
d <- check_feasibility(matrix(c(1,0,0,0),1),.97,upper=.5)
stopifnot(d$status=="infeasible_to_tolerance", abs(d$lower-.47)<1e-7,
          d$scope=="bounded_simplex")
e <- check_feasibility(matrix(c(1,0,0,0),1),.97)
stopifnot(abs(e$min_max_weight-.97)<1e-7)
f <- check_feasibility(diag(2),c(.5,.5),lower=.6)
stopifnot(f$status=="empty_weight_domain")
g <- audit_calibration(diag(2),c(.5,.5),raw=c(1,1),margin=c("A","A"),level=c("x","y"))
stopifnot(identical(g$raw$ledger$margin,c("A","A")),identical(g$raw$ledger$level,c("x","y")))
h <- audit_calibration(diag(2),c(.5,.5))
stopifnot(is.null(h$raw),h$feasibility$status=="attainable_to_tolerance")
cat("PASS certificate contract\n")
