# Real nonbiological built-in state dataset; illustrative selection, not a survey design.
population <- datasets::state.x77[,"Population"]
region <- datasets::state.region
M <- rbind(t(vapply(levels(region), function(x) as.numeric(region==x), numeric(50))),
           as.numeric(population>median(population)), as.numeric(population<=median(population)))
target <- rowMeans(M)
# Every observed joint pattern represented: exact feasibility guaranteed.
keep <- !duplicated(t(M))
a <- audit_calibration(M[,keep,drop=FALSE],target,rep(1,sum(keep)))
stopifnot(a$feasibility$status=="attainable_to_tolerance")
# Exclude Northeast deliberately: target positive but no support.
keep <- region!="Northeast"
b <- audit_calibration(M[,keep,drop=FALSE],target,rep(1,sum(keep)))
stopifnot(b$feasibility$status=="infeasible_to_tolerance",length(b$unsupported_rows)==1,
          abs(b$feasibility$lower-9/50)<1e-8)
cat("state.x77 positive control: tasks",sum(!duplicated(t(M))),"gap",a$raw$gap,
    "minimum",a$feasibility$upper,"\n")
cat("state.x77 missing-region control: tasks",sum(keep),"gap",b$raw$gap,
    "minimum",b$feasibility$lower,"\n")
