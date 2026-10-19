# Fluttractor

**Fluttractor** is a desktop application (macOS, Windows) for plotting phase portraits — including strange attractors — of systems of ordinary differential equations (ODEs).

> **Status:** early development. The numerical core is complete and covered by tests. The app shows an interactive 3D view of the Lorenz attractor that can be rotated with the mouse.

---

## Features

| Feature | Status |
|---|---|
| Systems of ODEs with an arbitrary number of variables and parameters | ✅ done (core) |
| Fixed-step integrators: explicit Euler, classical Runge–Kutta 4 | ✅ done (core) |
| Built-in Lorenz system | ✅ done (core) |
| 3D view of a trajectory with mouse-controlled camera rotation | ✅ done (single view) |
| Constant scale while rotating (bounding-sphere fit) | ✅ done |
| Computation in a background isolate | 📋 planned |
| Several views at once (user-selected triples of variables) | 📋 planned |
| Adaptive step size (Dormand–Prince 5(4)) | 📋 planned |
| Implicit method for stiff systems | 📋 planned |
| User-defined equations (formula parser + LaTeX preview) | 📋 planned |
| Export: PNG, EPS, SVG | 📋 planned |
| Presets: Lorenz, Rössler, Thomas, Sprott, Aizawa, … | 📋 planned |
| Lyapunov exponents and bifurcation diagrams | 📋 planned |

---

## Usage

The window shows the Lorenz attractor (σ = 10, ρ = 28, β = 8/3), integrated with RK4 from the point (1, 1, 1) on t ∈ [0, 50] with step h = 0.01.

* **Drag horizontally** — rotate the attractor around the vertical axis.
* **Drag vertically** — tilt the view, from looking straight from above to straight from below.
* **Resize the window** — the picture is rescaled to fit; its proportions are preserved.

---

## Repository structure

```
fluttractor/
├── lib/                                # Flutter application
│   ├── main.dart
│   ├── features/
│   │   └── viewer/
│   │       └── attractor_screen.dart   # screen: computes the trajectory, handles mouse drag
│   └── render/                         # pure functions + painter
│       ├── bounding_sphere.dart        # centre and radius of the visible triple of variables
│       ├── camera.dart                 # camera angles, mouse drag → angles
│       ├── rotation.dart               # turntable rotation (yaw, pitch) about a centre
│       ├── projection.dart             # 3D → screen pixels
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
 │  AttractorScreen          state: trajectory, bounding sphere (once), camera angles  │
 │        │  mouse drag → orbit() → new camera → setState                              │
 │        ▼                                                                            │
 │  TrajectoryPainter.paint:  rotate()  →  projectFixed()  →  Canvas.drawRawPoints()   │
 └──────────────────────────────────────▲──────────────────────────────────────────────┘
                                        │ Trajectory
 ┌──────────────────────── bg_calculator (pure Dart) ──────────────────────────────────┐
 │  OdeSystem  →  Stepper (Euler, RK4, …)  →  integrate()  →  Trajectory               │
 └─────────────────────────────────────────────────────────────────────────────────────┘
```

* **Core** computes trajectories: *what* to solve (`OdeSystem`), *how* to make one step (`Stepper`), *how* to walk the whole time interval (`integrate`), *where* to store the result (`Trajectory`).
* **App** turns a trajectory into pictures. Rotation and projection are pure functions, separated from drawing, so the same projected points can later be sent either to the screen or to a vector file.

### Rendering pipeline

1. **Triple of variables.** A view shows three of the system's *n* variables (x, y, z of the view). Time is not an axis: it is the parameter along the curve.
2. **Bounding sphere** — computed once per trajectory: the centre is the middle of the bounding box, the radius is the largest distance from the centre to a point.
3. **Rotation** — a turntable camera: *yaw* around the vertical axis, then *pitch* around the horizontal screen axis (limited to ±90°, so the picture never turns upside down). Points are rotated about the sphere centre.
4. **Orthographic projection** — depth is dropped; the scale is `(min(width, height) − 2·padding) / (2·radius)`. A rotation preserves distances, so the sphere always projects onto the same circle and the attractor keeps its size while being rotated.
5. **Painting** — `Canvas.drawRawPoints(PointMode.polygon, …)` with a hairline stroke.

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
* **Lorenz system** (σ = 10, ρ = 28, β = 8/3): right-hand side at known points, fixed points C±, symmetry (x, y, z) → (−x, −y, z); the trajectory stays finite and bounded and keeps switching between the two wings of the attractor.

### Rendering

* **Projection:** corners of the picture, one scale for both axes (aspect ratio is preserved), choice of axes, degenerate cases (a single point, zero span along one axis), padding; a smoke test on the real Lorenz trajectory.
* **Rotation:** identity, quarter turns (checks signs), *property-based* tests — distances between points and to the centre are preserved; *metamorphic* tests of the choice of variables and of rotation about a centre.
* **Bounding sphere:** a cube, a single point, box centre vs. arithmetic mean, maximum distance, a 4-variable system with a chosen triple.
* **Camera:** pitch is limited to ±90°.
* **Widgets:** the screen draws with `TrajectoryPainter`; the canvas fills the window and follows its resize; `shouldRepaint` reacts to every input that changes the picture.

---

## Roadmap

1. ~~Numerical core: system description, Euler and RK4, integrator, tests~~
2. ~~3D view with camera rotation (Lorenz)~~
3. Computation in a background isolate, state management
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
