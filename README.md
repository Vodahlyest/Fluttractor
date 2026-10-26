# Fluttractor

**Fluttractor** is a desktop application (macOS, Windows) for plotting phase portraits — including strange attractors — of systems of ordinary differential equations (ODEs).

> **Status:** early development. The numerical core is complete and covered by tests. The app shows an interactive 3D view of the Lorenz attractor that can be rotated with the mouse; the trajectory is computed in a background isolate, so the window stays responsive.

---

## Features

| Feature | Status |
|---|---|
| Systems of ODEs with an arbitrary number of variables and parameters | ✅ done (core) |
| Fixed-step integrators: explicit Euler, classical Runge–Kutta 4 | ✅ done (core) |
| Advancing a system in time without storing points (`evolve`) | ✅ done (core) |
| Discarding the initial part of a trajectory (transient) | ✅ done (parameter, off by default) |
| Built-in Lorenz system | ✅ done (core) |
| 3D view of a trajectory with mouse-controlled camera rotation | ✅ done (single view) |
| Constant scale while rotating (bounding-sphere fit) | ✅ done |
| Screen-space decimation of dense trajectories (~15× faster rasterisation) | ✅ done |
| Computation in a background isolate (Riverpod `FutureProvider`, loading and error states) | ✅ done |
| Several views at once (user-selected triples of variables) | 📋 planned |
| Adaptive step size (Dormand–Prince 5(4)) | 📋 planned |
| Implicit method for stiff systems | 📋 planned |
| User-defined equations (formula parser + LaTeX preview) | 📋 planned |
| Export: PNG, EPS, SVG | 📋 planned |
| Presets: Lorenz, Rössler, Thomas, Sprott, Aizawa, … | 📋 planned |
| Lyapunov exponents and bifurcation diagrams | 📋 planned |

---

## Usage

The window shows the Lorenz attractor (σ = 10, ρ = 28, β = 8/3), integrated with RK4 from the point (1, 1, 1) on t ∈ [0, 50] with step h = 0.01. While the trajectory is being computed, a progress indicator is shown; if the computation fails, the error is shown instead of the picture.

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
│   │   └── scene_provider.dart         # FutureProvider: computes the scene in an isolate
│   ├── constant_values/
│   │   └── indices.dart                # default triple of variables shown in the view
│   ├── calculations/                   # pure computations behind a view (no Flutter widgets)
│   │   ├── sphere.dart                 # Sphere record type
│   │   ├── bounding_sphere.dart        # centre and radius of the visible triple of variables
│   │   └── scene.dart                  # Scene = trajectory + sphere; computeScene(), …InIsolate()
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
│       │       └── systems/            # built-in systems (Lorenz)
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
 │        │  ref.watch(sceneProvider) → loading │ error │ data(Scene)                  │
 │        │  mouse drag → orbit() → new camera → setState                              │
 │        ▼                                                                            │
 │  TrajectoryPainter.paint:                                                           │
 │     rotate()  →  projectFixed()  →  decimate()  →  Canvas.drawRawPoints()           │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Scene (trajectory + sphere)
 ┌─────────────────────────────── providers (Riverpod) ────────────────────────────────┐
 │  sceneProvider: FutureProvider<Scene>  →  computeSceneInIsolate()                   │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Isolate.run: inputs copied, result moved
 ┌──────────────── calculations (lib/calculations), background isolate ────────────────┐
 │  computeScene():  evolve()  →  integrate()  +  boundingSphere()  →  Scene           │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Trajectory
 ┌───────────────────────────── bg_calculator (pure Dart) ─────────────────────────────┐
 │  OdeSystem  →  Stepper (Euler, RK4, …)  →  integrate()  →  Trajectory               │
 │                                         →  evolve()     →  state at t₁              │
 └─────────────────────────────────────────────────────────────────────────────────────┘
```

* **Core** computes trajectories: *what* to solve (`OdeSystem`), *how* to make one step (`Stepper`), *how* to walk the whole time interval (`integrate`), *where* to store the result (`Trajectory`). `evolve` walks the interval with exactly the same steps as `integrate` but keeps only the final state — used to skip a transient now, and later for Lyapunov exponents and bifurcation diagrams, where storing whole trajectories is wasteful.
* **Calculations** prepare what a view needs: the trajectory and its bounding sphere, bundled as a `Scene`. An optional `skipTime` (default 0) discards the initial part of the trajectory: the system is first advanced with `evolve` from t₀ to t₀ + `skipTime`, and only the rest is stored and shown. `computeScene` is a pure function; `computeSceneInIsolate` runs it in a background isolate with `Isolate.run`. The closure captures only the function's own arguments, the inputs are copied into the new isolate and the result is moved back without copying. If the computation throws, the returned `Future` completes with the original error.
* **Providers** connect calculations to the UI: `sceneProvider` (a Riverpod `FutureProvider`, automatic retry disabled — a computation error is deterministic) exposes the scene as loading / error / data. The camera is *not* in a provider: it is ephemeral state of one view and stays in the widget.
* **App** turns a trajectory into pictures. Rotation and projection are pure functions, separated from drawing, so the same projected points can later be sent either to the screen or to a vector file.

### Rendering pipeline

1. **Triple of variables.** A view shows three of the system's *n* variables (x, y, z of the view). Time is not an axis: it is the parameter along the curve.
2. **Bounding sphere** — computed once per trajectory: the centre is the middle of the bounding box, the radius is the largest distance from the centre to a point.
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

### Rendering

* **Projection:** corners of the picture, one scale for both axes (aspect ratio is preserved), choice of axes, degenerate cases (a single point, zero span along one axis), padding; a smoke test on the real Lorenz trajectory.
* **Rotation:** identity, quarter turns (checks signs), *property-based* tests — distances between points and to the centre are preserved; *metamorphic* tests of the choice of variables and of rotation about a centre.
* **Bounding sphere:** a cube, a single point, box centre vs. arithmetic mean, maximum distance, a 4-variable system with a chosen triple.
* **Scene:** `computeScene` gives exactly the same result as calling `integrate` and `boundingSphere` directly, and really uses the requested triple of variables. `computeSceneInIsolate` returns bit-for-bit the same scene as the synchronous version, and an error inside the isolate reaches the caller with its original type. With `skipTime`, the scene equals the manual chain `evolve` → `integrate`, the trajectory starts exactly at t₀ + `skipTime`, and a `skipTime` not shorter than the whole interval is rejected.
* **Decimation:** nothing is dropped when points are far apart; first and last points are always kept; comparison is made with the last *kept* point (slow drift is preserved); the threshold is inclusive; both axes and thresholds other than 1 px are covered. Each test was checked against a deliberately broken implementation (mutation testing).
* **Painter:** a fake canvas records what is drawn — sub-pixel points collapse to the two end points, points more than 1 px apart are all kept (so the threshold is measured in screen pixels, not in model units).
* **Camera:** pitch is limited to ±90°.
* **Widgets:** the screen draws with `TrajectoryPainter`; the canvas fills the window and follows its resize; `shouldRepaint` reacts to every input that changes the picture; a horizontal drag changes only yaw, a vertical drag changes only pitch, and a long drag stops pitch exactly at ±90°.
* **Loading states:** with the provider overridden, the screen shows a progress indicator while the scene is pending (and keeps showing it however much time passes), switches to the picture once the scene arrives, and shows the error text — including the original message — when the computation fails.
* **End to end:** one test runs the real provider and the real isolate (in real time, via `tester.runAsync`) and checks that the screen ends up drawing the full 5001-point trajectory.

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
