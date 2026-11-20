"""Regenerate bounded_parity.R from an independent per-task SciPy LP."""
import numpy as np
from scipy.optimize import linprog

rng = np.random.default_rng(8006)
for i in range(20):
    n, k = 8, 5
    M = rng.integers(0, 2, (k, n))
    M[:, 1] = M[:, 0]
    l = rng.random(n) * .04
    u = l + rng.random(n) * .3 + .11
    t = rng.random(k)
    p = linprog(np.r_[np.zeros(n), 1],
                A_ub=np.vstack((np.c_[M, -np.ones(k)], np.c_[-M, -np.ones(k)])),
                b_ub=np.r_[t, -t], A_eq=[np.r_[np.ones(n), 0]], b_eq=[1],
                bounds=[*zip(l, u), (0, None)], method="highs")
    assert p.success
    f = lambda a: ','.join(format(float(v), '.17g') for v in np.ravel(a))
    print(f'a <- check_feasibility(matrix(c({f(M)}),{k},{n},byrow=TRUE),c({f(t)}),lower=c({f(l)}),upper=c({f(u)})); stopifnot(abs(a$lower-{p.fun:.17g})<1e-7,abs(a$upper-{p.fun:.17g})<1e-7)')
print('cat("PASS 20 heterogeneous box constraints vs independent SciPy LP\\n")')
