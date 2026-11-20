"""Emit deterministic shared R fixtures with independent SciPy results."""
import numpy as np
from scipy.optimize import linprog

rng = np.random.default_rng(20261119)
print('cases <- list()')
for i in range(40):
    M = rng.integers(0, 2, (6, 10))
    t = rng.integers(0, 101, 6) / 100 if i % 2 else M @ rng.dirichlet(np.ones(10))
    # Independent direct primal LP, without support-pattern deduplication.
    p = linprog(np.r_[np.zeros(10), 1], A_ub=np.vstack([np.c_[M, -np.ones(6)], np.c_[-M, -np.ones(6)]]),
                b_ub=np.r_[t, -t], A_eq=[np.r_[np.ones(10), 0]], b_eq=[1], bounds=(0, None), method='highs')
    assert p.success
    mat = ','.join(map(str, M.ravel()))
    targets = ','.join(format(v, '.17g') for v in t)
    print(f'cases[[{i+1}]] <- list(M=matrix(c({mat}),6,10,byrow=TRUE),t=c({targets}),expected={p.fun:.17g})')
print('errors <- vapply(cases,function(z) {')
print(' a <- audit_calibration(z$M,z$t,rep(1,10))$feasibility; stopifnot(a$status != "solver_unresolved");')
print(' max(abs(c(a$lower,a$upper)-z$expected)) },numeric(1))')
print('stopifnot(max(errors)<1e-7); cat("PASS: 40 shared SciPy/lpSolve fixtures; maximum error",max(errors),"\\n")')
