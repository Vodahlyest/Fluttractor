# Fluttractor

**Fluttractor** is a desktop application (macOS, Windows) for plotting phase portraits — including strange attractors — of systems of ordinary differential equations (ODEs).

> **Status:** early development. The numerical core is complete and covered by tests. The app shows an interactive 3D view of a chaotic attractor that can be rotated with the mouse; for systems with more than three variables the view is a projection onto a chosen triple of variables. The trajectory is computed in a background isolate, so the window stays responsive.

---

## Features

| Feature | Status |
|---|---|
| Systems of ODEs with an arbitrary number of variables and parameters | ✅ done (core) |
| Fixed-step integrators: explicit Euler, classical Runge–Kutta 4 | ✅ done (core) |
| Advancing a system in time without storing points (`evolve`) | ✅ done (core) |
| Discarding the initial part of a trajectory (transient) | ✅ done (parameter, off by default) |
| Built-in systems: Lorenz (3D), hyperchaotic Rössler (4D) | ✅ done (core) |
| 3D view of a trajectory with mouse-controlled camera rotation | ✅ done (single view) |
| Constant scale while rotating (bounding-sphere fit) | ✅ done |
| Screen-space decimation of dense trajectories (~15× faster rasterisation) | ✅ done |
| Computation in a background isolate (Riverpod `FutureProvider`, loading and error states) | ✅ done |
| Projection onto a triple of variables (validated; one trajectory shared by all triples) | ✅ done |
| Choosing the triple in the UI; several views at once | 🚧 in progress |
| Adaptive step size (Dormand–Prince 5(4)) | 📋 planned |
| Implicit method for stiff systems | 📋 planned |
| User-defined equations (formula parser + LaTeX preview) | 📋 planned |
| Export: PNG, EPS, SVG | 📋 planned |
| Presets: Lorenz, Rössler, Thomas, Sprott, Aizawa, … | 📋 planned |
| Lyapunov exponents and bifurcation diagrams | 📋 planned |

---

## Usage

The window shows the hyperchaotic Rössler system (a = 0.25, b = 3, c = 0.5, d = 0.05; four variables x, y, z, w), integrated with RK4 from the point (−10, −6, 0, 10) on t ∈ [0, 200] with step h = 0.01, projected onto the triple (x, y, z). Choosing another triple in the window is the next step; for now the system and the triple are set in `lib/providers/` and `lib/constant_values/`. While the trajectory is being computed, a progress indicator is shown; if the computation fails, the error is shown instead of the picture.

* **Drag horizontally** — rotate the attractor around the vertical axis.
* **Drag vertically** — tilt the view, from looking straight from above to straight from below.
* **Resize the window** — the picture is rescaled to fit; its proportions are preserved.

---

## Repository structure

```
fluttractor/
├── lib/                                # Flutter application
│   ├── main.dart                       # ProviderScope at the root of the app
│   ├── features/
│   │   └── viewer/
│   │       └── attractor_screen.dart   # screen: loading / error / picture, handles mouse drag
│   ├── providers/
│   │   ├── system_provider.dart        # the ODE system being shown
│   │   ├── trajectory_provider.dart    # FutureProvider: integrates once, in an isolate
│   │   ├── view_axes_provider.dart     # Notifier: the selected triple of variables
│   │   └── scene_provider.dart         # FutureProvider.family: scene for a given triple
│   ├── constant_values/
│   │   └── indices.dart                # default triple of variables (ViewAxes)
│   ├── calculations/                   # pure computations behind a view (no Flutter widgets)
│   │   ├── sphere.dart                 # Sphere record type
│   │   ├── bounding_sphere.dart        # centre and radius of the visible triple of variables
│   │   ├── view_axes.dart              # ViewAxes record type and its validation
│   │   ├── compute_trajectory.dart     # computeTrajectory(), …InIsolate()
│   │   └── scene.dart                  # Scene = trajectory + sphere (what one view needs)
│   └── render/                         # pure functions + painter
│       ├── camera.dart                 # camera angles, mouse drag → angles
│       ├── rotation.dart               # turntable rotation (yaw, pitch) about a centre
│       ├── projection.dart             # 3D → screen pixels
│       ├── decimation.dart             # drops sub-pixel points before drawing
│       └── trajectory_painter.dart     # CustomPainter that draws the trajectory
├── test/                               # application tests (mirror lib/)
├── packages/
│   └── bg_calculator/                  # numerical core — pure Dart, no Flutter
│       ├── lib/
│       │   ├── bg_calculator.dart      # public API (exports)
│       │   └── src/
│       │       ├── ode_system.dart     # ODE system description
│       │       ├── vector_ops.dart     # vector operations (axpy)
│       │       ├── integrator.dart     # integration loop
│       │       ├── evolution.dart      # advance in time without storing points
│       │       ├── trajectory.dart     # trajectory storage
│       │       ├── steppers/           # numerical methods
│       │       └── systems/            # built-in systems (Lorenz, hyperchaotic Rössler)
│       └── test/                       # core tests
├── macos/  windows/                    # platform runners
└── README.md
```

The numerical core lives in a separate package on purpose: it has no dependency on Flutter, can be tested with plain `dart test`, can run inside an isolate and can be reused as a standalone library. See [`packages/bg_calculator/README.md`](packages/bg_calculator/README.md).

---

## Architecture

```
 ┌──────────────────────────────── Flutter app (lib/) ─────────────────────────────────┐
 │  AttractorScreen      state: camera angles (local, ephemeral)                       │
 │        │  axes = ref.watch(viewAxesProvider)                                        │
 │        │  ref.watch(sceneProvider(axes)) → loading │ error │ data(Scene)            │
 │        │  mouse drag → orbit() → new camera → setState                              │
 │        ▼                                                                            │
 │  TrajectoryPainter.paint:                                                           │
 │     rotate()  →  projectFixed()  →  decimate()  →  Canvas.drawRawPoints()           │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Scene (trajectory + sphere for these axes)
 ┌─────────────────────────────── providers (Riverpod) ────────────────────────────────┐
 │  systemProvider ──► trajectoryProvider ──► sceneProvider(axes)   (family)           │
 │        │            computed once,         awaits the trajectory,                   │
 │        │            in an isolate          computes the sphere for the axes         │
 │        └──► viewAxesProvider: selected triple, reset when the system changes        │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Isolate.run: inputs copied, result moved
 ┌──────────────── calculations (lib/calculations), background isolate ────────────────┐
 │  computeTrajectory():  evolve()  →  integrate()  →  Trajectory                      │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Trajectory
 ┌───────────────────────────── bg_calculator (pure Dart) ─────────────────────────────┐
 │  OdeSystem  →  Stepper (Euler, RK4, …)  →  integrate()  →  Trajectory               │
 │                                         →  evolve()     →  state at t₁              │
 └─────────────────────────────────────────────────────────────────────────────────────┘
```

* **Core** computes trajectories: *what* to solve (`OdeSystem`), *how* to make one step (`Stepper`), *how* to walk the whole time interval (`integrate`), *where* to store the result (`Trajectory`). `evolve` walks the interval with exactly the same steps as `integrate` but keeps only the final state — used to skip a transient now, and later for Lyapunov exponents and bifurcation diagrams, where storing whole trajectories is wasteful.
* **Calculations** prepare what a view needs. `computeTrajectory` integrates the system; an optional `skipTime` (default 0) discards the initial part of the trajectory: the system is first advanced with `evolve` from t₀ to t₀ + `skipTime`, and only the rest is stored and shown. `computeTrajectoryInIsolate` runs it in a background isolate with `Isolate.run`. The closure captures only the function's own arguments, the inputs are copied into the new isolate and the result is moved back without copying. If the computation throws, the returned `Future` completes with the original error. A `ViewAxes` record names the triple of variables a view shows; `checkAxes` rejects negative, out-of-range and repeated indices.
* **Providers** connect calculations to the UI, each computation keyed by exactly what it depends on. The trajectory does not depend on the triple, so `trajectoryProvider` integrates **once** (in an isolate) for the whole app; the bounding sphere does, so `sceneProvider` is a family keyed by `ViewAxes`: it awaits the shared trajectory and computes only the sphere for its triple. Switching the triple therefore never re-integrates the system, and several views (next step) will share one trajectory. `viewAxesProvider` keeps the selected triple, validates new ones against the system's dimension and resets to the default when the system changes. Automatic retry is disabled — a computation error is deterministic. The camera is *not* in a provider: it is ephemeral state of one view and stays in the widget.
* **App** turns a trajectory into pictures. Rotation and projection are pure functions, separated from drawing, so the same projected points can later be sent either to the screen or to a vector file.

### Rendering pipeline

1. **Triple of variables.** A view shows three of the system's *n* variables (`ViewAxes`: axis1, axis2, axis3). The order matters: (2, 0, 1) and (0, 1, 2) give different pictures — an even permutation is a rotation, an odd one a mirror image. Time is not an axis: it is the parameter along the curve.
2. **Bounding sphere** — computed once per trajectory and triple: the centre is the middle of the bounding box, the radius is the largest distance from the centre to a point.
3. **Rotation** — a turntable camera: *yaw* around the vertical axis, then *pitch* around the horizontal screen axis (limited to ±90°, so the picture never turns upside down). Points are rotated about the sphere centre.
4. **Orthographic projection** — depth is dropped; the scale is `(min(width, height) − 2·padding) / (2·radius)`. A rotation preserves distances, so the sphere always projects onto the same circle and the attractor keeps its size while being rotated.
5. **Decimation** — a point is dropped if it lies closer than 1 px on screen to the last kept point (radial-distance simplification). The picture changes by less than a pixel, but a dense trajectory sends ~15× fewer segments to the GPU: 500 001 points shrink to about 30 000, roughly the curve's length in pixels.
6. **Painting** — `Canvas.drawRawPoints(PointMode.polygon, …)` with a hairline stroke.

---

## Getting started

### Requirements

* Flutter (stable channel), Dart SDK ≥ 3.13
* macOS: Xcode; Windows: Visual Studio with the “Desktop development with C++” workload

### Run

```bash
git clone https://github.com/Vodahlyest/Fluttractor.git
cd Fluttractor
flutter pub get
flutter run -d macos      # or: flutter run -d windows
```

### Tests

```bash
# numerical core
cd packages/bg_calculator
dart test

# application
cd ../..
flutter test
```

---

## Verification

### Numerical core

The core is checked against problems with known behaviour:

* **Harmonic oscillator** (exact solution known): one-step and full-trajectory accuracy; the *observed order of convergence* is ≈ 4.1 for RK4 and ≈ 1.0 for Euler, as theory predicts.
* **Polynomial forcing** (RK4 is exact for it): checks that time is passed to the method correctly.
* **`evolve`:** the final state is bit-for-bit equal to the last point of `integrate` on the same interval; advancing to t₁ and then integrating to t₂ gives exactly the same result as integrating from t₀ to t₂ (on a forced oscillator with a power-of-two step, so that both time grids coincide bit for bit; a mutation that forgets the start time is caught); a zero interval returns a copy of the input; the input is never modified; a reversed interval or a non-positive step throws `ArgumentError`.
* **Lorenz system** (σ = 10, ρ = 28, β = 8/3): right-hand side at known points, fixed points C±, symmetry (x, y, z) → (−x, −y, z); the trajectory stays finite and bounded and keeps switching between the two wings of the attractor.
* **Hyperchaotic Rössler system** (Rössler, 1979): right-hand side at a point computed by hand, names, parameters and dimension; a long trajectory stays finite and bounded (a sign mutation in the equations is caught).

### Rendering

* **Projection:** corners of the picture, one scale for both axes (aspect ratio is preserved), choice of axes, degenerate cases (a single point, zero span along one axis), padding; a smoke test on the real Lorenz trajectory.
* **Rotation:** identity, quarter turns (checks signs), *property-based* tests — distances between points and to the centre are preserved; *metamorphic* tests of the choice of variables and of rotation about a centre.
* **Bounding sphere:** a cube, a single point, box centre vs. arithmetic mean, maximum distance, a 4-variable system with a chosen triple.
* **Trajectory computation:** `computeTrajectory` gives exactly the same result as `integrate` and as the manual chain `evolve` → `integrate`; the trajectory starts exactly at t₀ + `skipTime`; a `skipTime` not shorter than the whole interval is rejected. `computeTrajectoryInIsolate` returns bit-for-bit the same trajectory, and an error inside the isolate reaches the caller with its original type.
* **View axes:** valid triples for 3 and 4 variables pass; a negative index, an index equal to the dimension and each of the three possible repeats throw `ArgumentError` (each case breaks exactly one rule).
* **Providers:** the scene for a triple holds the very trajectory object from the trajectory provider and the sphere for that triple; for two different triples the trajectory is computed **once** (a call counter on the overridden provider) and shared; the selected triple starts at the default, accepts a valid triple and rejects an invalid one without changing state.
* **Decimation:** nothing is dropped when points are far apart; first and last points are always kept; comparison is made with the last *kept* point (slow drift is preserved); the threshold is inclusive; both axes and thresholds other than 1 px are covered. Each test was checked against a deliberately broken implementation (mutation testing).
* **Painter:** a fake canvas records what is drawn — sub-pixel points collapse to the two end points, points more than 1 px apart are all kept (so the threshold is measured in screen pixels, not in model units).
* **Camera:** pitch is limited to ±90°.
* **Widgets:** the screen draws with `TrajectoryPainter`; the canvas fills the window and follows its resize; `shouldRepaint` reacts to every input that changes the picture; a horizontal drag changes only yaw, a vertical drag changes only pitch, and a long drag stops pitch exactly at ±90°.
* **Loading states:** with the trajectory provider overridden, the screen shows a progress indicator while the trajectory is pending (and keeps showing it however much time passes), switches to the picture once it arrives and the scene is built, and shows the error text — including the original message — when the computation fails.
* **End to end:** one test runs the real providers and the real isolate (in real time, via `tester.runAsync`) and checks that the screen ends up drawing the full 20 001-point trajectory of the hyperchaotic Rössler system.

---

## Roadmap

1. ~~Numerical core: system description, Euler and RK4, integrator, tests~~
2. ~~3D view with camera rotation (Lorenz)~~
3. ~~Computation in a background isolate, state management~~
4. Several views: user-selected triples of variables
5. Adaptive step size (Dormand–Prince)
6. User-defined equations
7. Export (PNG, EPS, SVG)
8. Implicit method for stiff systems
9. UI polish, presets
10. Lyapunov exponents and bifurcation diagrams
11. Equations of the quantum-emitter ensemble

---

## Author

Daniil Pavlov, 2026–2027.

## License

[GPL-3.0](LICENSE)
