# Fluttractor

**Fluttractor** is a desktop application (macOS, Windows) for plotting phase portraits — including strange attractors — of systems of ordinary differential equations (ODEs).

> **Status:** early development. The numerical core is complete and covered by tests. The app shows up to four interactive 3D views of a chaotic attractor at once, tiled automatically; each view is rotated with the mouse independently and, for systems with more than three variables, shows a projection onto its own triple of variables chosen in the window. The trajectory is computed once, in a background isolate, so the window stays responsive.

---

## Features

| Feature | Status |
|---|---|
| Systems of ODEs with an arbitrary number of variables and parameters | ✅ done (core) |
| Fixed-step integrators: explicit Euler, classical Runge–Kutta 4 | ✅ done (core) |
| Advancing a system in time without storing points (`evolve`) | ✅ done (core) |
| Discarding the initial part of a trajectory (transient) | ✅ done (parameter, off by default) |
| Built-in systems: Lorenz (3D), hyperchaotic Rössler (4D) | ✅ done (core) |
| 3D view of a trajectory with mouse-controlled camera rotation | ✅ done (own camera per view) |
| Constant scale while rotating (bounding-sphere fit) | ✅ done |
| Screen-space decimation of dense trajectories (~15× faster rasterisation) | ✅ done |
| Computation in a background isolate (Riverpod `FutureProvider`, loading and error states) | ✅ done |
| Projection onto a triple of variables (validated; one trajectory shared by all triples) | ✅ done |
| Choosing the triple in the window (bottom sheet; a taken variable swaps the axes) | ✅ done |
| Several views at once: up to 4, automatic tiling, added and removed in the window | ✅ done |
| Adaptive step size (Dormand–Prince 5(4)) | 📋 planned |
| Implicit method for stiff systems | 📋 planned |
| User-defined equations (formula parser + LaTeX preview) | 📋 planned |
| Export: PNG, EPS, SVG | 📋 planned |
| Presets: Lorenz, Rössler, Thomas, Sprott, Aizawa, … | 📋 planned |
| Lyapunov exponents and bifurcation diagrams | 📋 planned |

---

## Usage

The window starts with one view of the hyperchaotic Rössler system (a = 0.25, b = 3, c = 0.5, d = 0.05; four variables x, y, z, w), integrated with RK4 from the point (−10, −6, 0, 10) on t ∈ [0, 200] with step h = 0.01, projected onto the triple (x, y, z). The system is set in `lib/providers/system_provider.dart`; the default triple in `lib/constant_values/indices.dart`, the maximum number of views in `view_limit.dart` and the gap between views in `tile_gap.dart` next to it. While the trajectory is being computed, a progress indicator is shown; if the computation fails, the error is shown instead of the picture.

* **Drag horizontally** — rotate the attractor in that view around the vertical axis.
* **Drag vertically** — tilt the view, from looking straight from above to straight from below.
* **Resize the window** — the views are re-tiled and every picture is rescaled to fit its tile; proportions and camera angles are preserved.
* **Settings button** (top left of a view) — opens a sheet with three rows of chips: *width*, *depth* and *height*, one row per axis of the view (as seen with the camera in its start position). Choosing a variable already used by another axis swaps the two axes, so the triple is always valid and any permutation takes one click. The camera of that view returns to its start position whenever its triple changes; other views are not affected.
* **Add button** (`+`, bottom right) — adds a view with the default triple. Views are tiled automatically: two side by side (one above the other in a tall window), three as one large view and two smaller ones, four as a 2 × 2 grid. The button disappears when four views are shown.
* **Close button** (`×`, top right of a view) — removes that view; the remaining views keep their triples and camera angles. Hidden while only one view is left.

---

## Repository structure

```
fluttractor/
├── lib/                                # Flutter application
│   ├── main.dart                       # ProviderScope at the root of the app
│   ├── features/
│   │   ├── custom_widgets/
│   │   │   └── view_bottom_list.dart   # ViewBottomSheet: axis chips of one view
│   │   └── viewer/
│   │       ├── attractor_screen.dart   # screen: tiles the views, add button
│   │       ├── tiling.dart             # buildTiles(): rectangles for 1–4 views
│   │       └── view_panel.dart         # one view: own camera, loading / error / picture
│   ├── providers/
│   │   ├── system_provider.dart        # the ODE system being shown
│   │   ├── trajectory_provider.dart    # FutureProvider: integrates once, in an isolate
│   │   ├── plot_view_provider.dart     # Notifier: list of views (id + triple)
│   │   └── scene_provider.dart         # FutureProvider.family: scene for a given triple
│   ├── constant_values/
│   │   ├── indices.dart                # default triple of variables (ViewAxes)
│   │   ├── view_limit.dart             # maximum number of views (4)
│   │   └── tile_gap.dart               # gap between views, logical pixels
│   ├── calculations/                   # pure computations behind a view (no Flutter widgets)
│   │   ├── sphere.dart                 # Sphere record type
│   │   ├── bounding_sphere.dart        # centre and radius of the visible triple of variables
│   │   ├── view_axes.dart              # ViewAxes record type, validation, axis swapping
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
 │  AttractorScreen:  views = ref.watch(plotViewProvider)                              │
 │        │  LayoutBuilder → buildTiles(count, size) → flat Stack of                   │
 │        │  Positioned(key: ValueKey(view), rect: tile) → ViewPanel(view, onClose)    │
 │        │  add button → addNewPlotView()          (hidden at viewLimit)              │
 │        ▼                                                                            │
 │  ViewPanel (one per view)    state: camera angles (local, ephemeral)                │
 │        │  ref.watch(sceneProvider(view.axes)) → loading │ error │ data(Scene)       │
 │        │  mouse drag → orbit() → new camera → setState                              │
 │        │  settings → bottom sheet: chip → swap → setNewTripletForId(id, axes)       │
 │        │  close → onClose → removeViewById(id)    (null while one view is left)     │
 │        ▼                                                                            │
 │  TrajectoryPainter.paint:                                                           │
 │     rotate()  →  projectFixed()  →  decimate()  →  Canvas.drawRawPoints()           │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Scene (trajectory + sphere for these axes)
 ┌─────────────────────────────── providers (Riverpod) ────────────────────────────────┐
 │  systemProvider ──► trajectoryProvider ──► sceneProvider(axes)   (family)           │
 │        │            computed once,         awaits the trajectory,                   │
 │        │            in an isolate          computes the sphere for the axes         │
 │        └──► plotViewProvider: views (id + triple), reset when the system changes    │
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
* **Calculations** prepare what a view needs. `computeTrajectory` integrates the system; an optional `skipTime` (default 0) discards the initial part of the trajectory: the system is first advanced with `evolve` from t₀ to t₀ + `skipTime`, and only the rest is stored and shown. `computeTrajectoryInIsolate` runs it in a background isolate with `Isolate.run`. The closure captures only the function's own arguments, the inputs are copied into the new isolate and the result is moved back without copying. If the computation throws, the returned `Future` completes with the original error. A `ViewAxes` record names the triple of variables a view shows; `checkAxes` rejects negative, out-of-range and repeated indices; `setAxesWithParameters` puts a variable on an axis and, if another axis already shows it, swaps the two axes.
* **Providers** connect calculations to the UI, each computation keyed by exactly what it depends on. The trajectory does not depend on the triple, so `trajectoryProvider` integrates **once** (in an isolate) for the whole app; the bounding sphere does, so `sceneProvider` is a family keyed by `ViewAxes`: it awaits the shared trajectory and computes only the sphere for its triple. Switching a triple therefore never re-integrates the system, and all views share one trajectory; views with the same triple share one scene. `plotViewProvider` keeps the list of views, each a record of an id and a triple: it adds views up to the limit, removes them (never the last one) and changes a triple by id, validates every triple against the system's dimension and resets to one default view when the system changes. An id is the largest existing id + 1 and never changes, so a view keeps its identity when another view is removed. Automatic retry is disabled — a computation error is deterministic. The camera is *not* in a provider: it is ephemeral state of one view and stays in that view's widget. The bottom sheet is a separate route in the `Navigator`, not a child of the screen, so it does not rebuild with the screen: it is a `ConsumerWidget` that watches the providers itself and always computes the next triple from the current one.
* **Views and tiling.** `buildTiles` is a pure function from the number of views and the size of the area to a list of rectangles; the layout depends on the orientation (a square area counts as wide), and every rectangle is then shrunk by half the gap, so neighbours are separated by exactly `tileGap`. The screen measures its area with a `LayoutBuilder` and places the views in one flat `Stack` of `Positioned` widgets keyed by `ValueKey(view)`. The `Stack` is flat because nested `Row`/`Column` widgets would move a view to a different parent whenever the number of views changes, and keys are matched only among children of one parent, so the view's state — its camera — would be lost. The key sits on `Positioned`, the direct child of the `Stack`, because that is the level at which the `Stack` matches its children: adding, removing or re-tiling views moves the existing views instead of recreating them. The key includes the triple, so changing a triple recreates only that view, which resets its camera without any explicit listener. The close button takes a nullable callback, following the Flutter convention for `onPressed`: the screen passes `null` while only one view is left, and the view hides the button.
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
* **View axes:** valid triples for 3 and 4 variables pass; a negative index, an index equal to the dimension and each of the three possible repeats throw `ArgumentError` (each case breaks exactly one rule). Swapping: a variable taken by another axis (both directions), a free variable, the same variable on the same axis, and an axis number outside 1…3 (`ArgumentError`).
* **Providers:** the scene for a triple holds the very trajectory object from the trajectory provider and the sphere for that triple; for two different triples the trajectory is computed **once** (a call counter on the overridden provider) and shared. The list of views starts with one default view; adding assigns the next id and fails at the limit with `StateError`; ids do not change when a view is removed; the last view cannot be removed; changing a triple affects only the view with that id; an invalid triple or an unknown id throws `ArgumentError`.
* **Tiling:** exact rectangles for 1–4 views in wide and tall areas, a square area counts as wide; properties for every count and orientation — the rectangles lie inside the area, no two of them overlap (every pair is checked) and without a gap their areas add up to the whole area; with a gap every rectangle is the gap-free one shrunk by half the gap; a number of views outside 1…limit throws `ArgumentError`.
* **Decimation:** nothing is dropped when points are far apart; first and last points are always kept; comparison is made with the last *kept* point (slow drift is preserved); the threshold is inclusive; both axes and thresholds other than 1 px are covered. Each test was checked against a deliberately broken implementation (mutation testing).
* **Painter:** a fake canvas records what is drawn — sub-pixel points collapse to the two end points, points more than 1 px apart are all kept (so the threshold is measured in screen pixels, not in model units).
* **Camera:** pitch is limited to ±90°.
* **Widgets:** the screen draws with `TrajectoryPainter`; the canvas fills the window except the frame of half the gap and follows its resize; `shouldRepaint` reacts to every input that changes the picture; a horizontal drag changes only yaw, a vertical drag changes only pitch, and a long drag stops pitch exactly at ±90°.
* **Loading states:** with the trajectory provider overridden, the screen shows a progress indicator while the trajectory is pending (and keeps showing it however much time passes), switches to the picture once it arrives and the scene is built, and shows the error text — including the original message — when the computation fails.
* **Bottom sheet:** the settings button opens it with a chip per variable and axis and the current triple highlighted; one tap updates the provider, the painter and the still-open sheet together; two taps in a row in one open sheet build on each other (a regression test for a sheet that computed every swap from the triple captured when it was opened); changing the triple resets a rotated camera.
* **Several views:** the add button adds views and disappears at the limit; close buttons appear only when there is more than one view and remove exactly their own view; a rotated camera survives adding a view, removing a neighbour and changing a neighbour's triple. The tests were checked against broken keys: moving the key from `Positioned` one level down breaks the test with a removed neighbour, while the test with an added view still passes — appending a view does not shift the existing ones, removing the first one does.
* **End to end:** one test runs the real providers and the real isolate (in real time, via `tester.runAsync`) and checks that the screen ends up drawing the full 20 001-point trajectory of the hyperchaotic Rössler system.

---

## Roadmap

1. ~~Numerical core: system description, Euler and RK4, integrator, tests~~
2. ~~3D view with camera rotation (Lorenz)~~
3. ~~Computation in a background isolate, state management~~
4. ~~Several views: user-selected triples of variables~~
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
