"""Independent two-step per-task SciPy LP for bounded concentration."""
import numpy as np
from scipy.optimize import linprog

rng = np.random.default_rng(8007)
for i in range(20):
    n, k = 8, 5
    M = rng.integers(0, 2, (k, n))
    M[:, 1] = M[:, 0]
    l = rng.random(n) * .04
    u = l + rng.random(n) * .3 + .11
    t = rng.random(k)
    obj = np.r_[np.zeros(n), 1]
    eq = [np.r_[np.ones(n), 0]]
    bounds = [*zip(l, u), (0, None)]
    p = linprog(obj, A_ub=np.vstack((np.c_[M, -np.ones(k)], np.c_[-M, -np.ones(k)])),
                b_ub=np.r_[t, -t], A_eq=eq, b_eq=[1], bounds=bounds, method="highs")
    assert p.success
    # Minimize maximum original weight at optimum residual (tiny numerical slack).
    q = linprog(obj, A_ub=np.vstack((np.c_[M, np.zeros(k)], np.c_[-M, np.zeros(k)],
                                   np.c_[np.eye(n), -np.ones(n)])),
                b_ub=np.r_[t+p.fun+1e-10, -t+p.fun+1e-10, np.zeros(n)],
                A_eq=eq, b_eq=[1], bounds=bounds, method="highs")
    assert q.success
    f = lambda a: ','.join(format(float(v), '.17g') for v in np.ravel(a))
    print(f'a <- check_feasibility(matrix(c({f(M)}),{k},{n},byrow=TRUE),c({f(t)}),lower=c({f(l)}),upper=c({f(u)})); stopifnot(abs(a$upper-{p.fun:.17g})<1e-7,abs(a$min_max_weight-{q.fun:.17g})<1e-7)')
print('cat("PASS 20 bounded concentration cases vs independent two-step SciPy LP\\n")')
