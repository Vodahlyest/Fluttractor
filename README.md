# Fluttractor

**Fluttractor** is a desktop application (macOS, Windows) for plotting phase portraits — including strange attractors — of systems of ordinary differential equations (ODEs).

> **Status:** early development. The numerical core is complete and covered by tests; visualisation is in progress.

---

## Features

| Feature | Status |
|---|---|
| Systems of ODEs with an arbitrary number of variables and parameters | ✅ done (core) |
| Fixed-step integrators: explicit Euler, classical Runge–Kutta 4 | ✅ done (core) |
| Built-in Lorenz system | ✅ done (core) |
| 3D view of a trajectory with mouse-controlled camera rotation | 🚧 in progress |
| Several views at once (user-selected triples of variables) | 📋 planned |
| Adaptive step size (Dormand–Prince 5(4)) | 📋 planned |
| Implicit method for stiff systems | 📋 planned |
| User-defined equations (formula parser + LaTeX preview) | 📋 planned |
| Export: PNG, EPS, SVG | 📋 planned |
| Presets: Lorenz, Rössler, Thomas, Sprott, Aizawa, … | 📋 planned |

---

## Repository structure

```
fluttractor/
├── lib/                      # Flutter application (UI, rendering)
├── test/                     # application tests
├── packages/
│   └── bg_calculator/        # numerical core — pure Dart, no Flutter
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
├── macos/  windows/          # platform runners
└── README.md
```

The numerical core lives in a separate package on purpose: it has no dependency on Flutter, can be tested with plain `dart test`, can run inside an isolate, and is described in the thesis as a standalone library. See [`packages/bg_calculator/README.md`](packages/bg_calculator/README.md).

---

## Architecture

```
 ┌──────────────────────────── Flutter app (lib/) ───────────────────────────┐
 │  UI: parameters, presets, views   →   projection 3D → 2D   →   painter    │
 │                                                       └─────→   exporter  │
 └───────────────────────────────▲───────────────────────────────────────────┘
                                 │ Trajectory
 ┌──────────────────── bg_calculator (pure Dart) ────────────────────────────┐
 │  OdeSystem  →  Stepper (Euler, RK4, …)  →  integrate()  →  Trajectory      │
 └───────────────────────────────────────────────────────────────────────────┘
```

* **Core** computes trajectories: *what* to solve (`OdeSystem`), *how* to make one step (`Stepper`), *how* to walk the whole time interval (`integrate`), *where* to store the result (`Trajectory`).
* **App** turns a trajectory into pictures. Projection to 2D is separated from drawing, so the same projected lines can be sent either to the screen or to a vector file.

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

## Verification of the numerical core

The core is checked against problems with known behaviour:

* **Harmonic oscillator** (exact solution known): one-step and full-trajectory accuracy; the *observed order of convergence* is ≈ 4.1 for RK4 and ≈ 1.0 for Euler, as theory predicts.
* **Polynomial forcing** (RK4 is exact for it): checks that time is passed to the method correctly.
* **Lorenz system** (σ = 10, ρ = 28, β = 8/3): right-hand side at known points, fixed points C±, symmetry (x, y, z) → (−x, −y, z); the trajectory stays finite and bounded and keeps switching between the two wings of the attractor.

---

## Roadmap

1. ~~Numerical core: system description, Euler and RK4, integrator, tests~~
2. 3D view with camera rotation (Lorenz)
3. Several views: user-selected triples of variables
4. Adaptive step size (Dormand–Prince)
5. User-defined equations
6. Export (PNG, EPS, SVG)
7. Implicit method for stiff systems
8. UI polish, presets
9. Equations of the quantum-emitter ensemble

---

## Author

Daniil Pavlov, 2026–2027.

## License

[GPL-3.0](LICENSE)
