if (Sys.getenv("CALIBCHECK_SOURCE") != "") {
  source(Sys.getenv("CALIBCHECK_SOURCE"))
} else library(calibcheck)

near <- function(x, y, tol=1e-8) stopifnot(abs(x-y) <= tol)
M <- rbind(c(1,0), c(0,1), c(1,0), c(0,1))
a <- audit_calibration(M, c(.9,.1,.1,.9), c(.1,.9), c(.18,.82), TRUE)
stopifnot(a$feasibility$status == "infeasible_to_tolerance", a$numerical_converged,
          !a$raw$balanced, !a$final$balanced, length(a$unsupported_rows)==0)
near(a$feasibility$lower,.4); near(a$feasibility$upper,.4)
near(a$raw$gap,.8); near(a$final$gap,.72)
M <- rbind(c(1,0,1,0), c(0,1,0,1))
b <- audit_calibration(M, c(.9,.1), c(.45,.05,.45,.05), c(.41,.09,.41,.09), FALSE,
                       case_id=c("a","a","b","b"))
stopifnot(b$feasibility$status == "attainable_to_tolerance", !b$numerical_converged,
          b$raw$balanced, !b$final$balanced)
near(b$final$gap,.08); near(b$raw$case_ess,2); near(b$raw$task_ess,1/.41)
c <- audit_calibration(rbind(c(0,0),c(1,1)),c(.2,.8),c(1,1))
stopifnot(identical(c$unsupported_rows,1L), is.na(c$numerical_converged), is.null(c$final))
near(c$feasibility$lower,.2)
d <- audit_calibration(matrix(c(1,0), nrow=1),1,c(1,0))
stopifnot(d$raw$balanced, d$raw$zero_weights==1, d$feasibility$status=="attainable_to_tolerance")
stopifnot(inherits(try(audit_calibration(matrix(c(1,0),1),.5,c(-1,2)),silent=TRUE),"try-error"))
stopifnot(inherits(try(audit_calibration(matrix(c(1,0),1),.5,c(0,0)),silent=TRUE),"try-error"))
stopifnot(inherits(try(audit_calibration(matrix(c(1,0),1),.5,c(1,1),case_id=c("a",NA)),silent=TRUE),"try-error"))
cat("PASS: contradiction, shrinkage, flag independence, support, ESS, boundary and validation\n")
v <- verify_certificate(rbind(c(1,0),c(0,1),c(1,0),c(0,1)),c(9,1,1,9),10,
                        c(1,1),c(1,0,-1,0),2)
stopifnot(v$lower_num==8, v$lower_den==20, v$upper_num==8, v$upper_den==20)
stopifnot(inherits(try(verify_certificate(matrix(c(1,0),1),1,2,c(1,1),2,1),silent=TRUE),"try-error"))
cat("PASS: exact integer certificate and invalid witness rejection\n")
