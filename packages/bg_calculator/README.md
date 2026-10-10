# bg_calculator

Numerical core of [Fluttractor](../../README.md): a pure Dart library for integrating systems of ordinary differential equations (ODEs) and storing the resulting trajectories.

The package has **no Flutter dependency**. It can be tested with `dart test`, run inside an isolate and reused outside the application.

---

## Features

* Description of an ODE system **dy/dt = f(t, y, p)** with any number of variables `n` and parameters.
* Fixed-step one-step methods behind a common `Stepper` interface:
  * `ExplicitEuler` — order 1;
  * `Rk4` — classical Runge–Kutta, order 4.
* `integrate()` — walks the time interval with an integer number of steps and returns a `Trajectory`.
* `Trajectory` — compact storage of all points in flat `Float64List`s.
* Built-in system: `lorenz` (σ = 10, ρ = 28, β = 8/3).

---

## Usage

```dart
import 'dart:typed_data';
import 'package:bg_calculator/bg_calculator.dart';

void main() {
  final stepper = Rk4(system: lorenz);
  final y0 = Float64List.fromList([1.0, 1.0, 1.0]);

  final trajectory = integrate(stepper, y0, 0.0, 50.0, 0.01);

  final last = trajectory.points - 1;
  print('t = ${trajectory.time[last]}, state = ${trajectory.stateAt(last)}');
}
```

### Defining your own system

A system is described by variable names, parameter names, parameter values and a right-hand side function:

```dart
// Harmonic oscillator: x' = v, v' = -omega^2 * x
final oscillator = OdeSystem(
  variableNames: ['x', 'v'],
  parameterNames: ['omega'],
  parameters: [2.0],
  rhs: (t, state, p, dydt) {
    final omega = p[0];
    dydt[0] = state[1];
    dydt[1] = -omega * omega * state[0];
  },
);
```

Contract of the right-hand side (`RightSide`):

* write **all** `n` components of `dydt`, in the same order as `variableNames`;
* do **not** modify `state` or `p`;
* do **not** keep references to the lists — the integrator reuses its buffers.

Parameters are changed by creating a new system: `lorenz.withParameters([10, 99, 8 / 3])`. `OdeSystem` is immutable.

---

## Design notes

| Decision | Reason |
|---|---|
| One vector function `f` instead of `n` scalar ones | shared sub-expressions (e.g. collective fields in an emitter ensemble) are computed once per call |
| `f` writes into an output buffer instead of returning a list | no allocations in the hot loop (RK4 calls `f` 4 times per step) |
| `Float64List` for state and stage buffers | contiguous memory, no boxing, fixed length |
| Stage buffers allocated once in the stepper's constructor | nothing is allocated per step |
| Integer number of steps, `t_i = t0 + i·h'` | the interval end is always reached; no accumulation of round-off in time |
| Requested step `h` is adjusted to `h' = (tEnd − t0) / N`, `N = ceil((tEnd − t0) / h)` | `h' ≤ h`, the last point is exactly at `tEnd` |
| Trajectory stored in one flat array, point `i` at `[i·n, (i+1)·n)` | one object instead of thousands, cheap transfer between isolates |
| `stateAt(i)` returns a **view**, not a copy | no allocation; modifying the view modifies the trajectory |

---

## Verification

Run the tests:

```bash
dart test
```

| Test file | What it checks |
|---|---|
| `ode_system_test.dart` | validation, immutability, defensive copies, `withParameters` |
| `vector_ops_test.dart` | `axpy`, including aliased buffers |
| `lorenz_test.dart` | right-hand side at a point, fixed points C±, symmetry, parameters taken from `p` |
| `explicit_euler_test.dart`, `rk4_test.dart` | one step on a harmonic oscillator; time dependence; assertions |
| `trajectory_test.dart` | layout of the flat array, views, index checks |
| `integrator_test.dart` | time grid, step adjustment, independence of points, accuracy vs exact solution, `t0 ≠ 0` |
| `convergence_test.dart` | observed order of convergence: ≈ 4 for RK4, ≈ 1 for Euler |
| `lorenz_attractor_test.dart` | trajectory is finite, bounded and chaotic (switches between the wings) |

---

## Limitations (current version)

* fixed step only — no error control yet (Dormand–Prince is planned);
* explicit methods only — not suitable for stiff systems;
* `integrate()` does not yet validate its arguments and stores every step.

## References

* Hairer E., Nørsett S. P., Wanner G. *Solving Ordinary Differential Equations I: Nonstiff Problems.* 2nd ed. Springer, 1993.
* Strogatz S. H. *Nonlinear Dynamics and Chaos.* 2nd ed. CRC Press, 2018.
* Lorenz E. N. Deterministic Nonperiodic Flow // *Journal of the Atmospheric Sciences.* 1963. Vol. 20, No. 2. P. 130–141.
