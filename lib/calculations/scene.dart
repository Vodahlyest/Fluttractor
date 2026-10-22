import 'dart:typed_data';
import 'dart:isolate';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:fluttractor/calculations/sphere.dart';
import 'package:fluttractor/calculations/bounding_sphere.dart';

/// defines a type for a record that contains Ode soulution
/// [trajectory] and bounding sphere of it [sphere]
typedef Scene = ({Trajectory trajectory, Sphere sphere});

/// returns a Scene record for the chosen system to solve
///
/// guarantees: clean function that does not capture anything
/// which is safe for running in the separate isolate
///
/// parameters:
/// - [stepper] - which method is used for the calculation
/// - [y0] - initial conditions, set by the problem
/// - [t0] - start point of the time segment of interest
/// - [tEnd] - end point of the time segment of interest
/// - [h] - step of calculation
/// - [xIndex] - x of the point's index for the Bounding sphere
///              (see Trajectory's declaration in bg_calculator)
/// - [yIndex] - y of the point's index for the Bounding sphere
/// - [zIndex] - z of the point's index for the Bounding sphere
Scene computeScene({
  required Stepper stepper,
  required Float64List y0,
  required double t0,
  required double tEnd,
  required double h,
  required int xIndex,
  required int yIndex,
  required int zIndex,
}) {
  final trajectory = integrate(stepper, y0, t0, tEnd, h);
  return (
    trajectory: trajectory,
    sphere: boundingSphere(trajectory, xIndex, yIndex, zIndex),
  );
}

/// Runs [computeScene] in a separate isolate, returning Future of
/// a scene
///
/// guarantees: safe work with an isolate: isolate gets access
/// only to the data passed as an arguments for this function
/// if the calculations resulted in error, returned Future
/// is unpacked with the error that was thrown, not RemoteError
///
/// parameters are the same as for the [computeScene]
Future<Scene> computeSceneInIsolate({
  required Stepper stepper,
  required Float64List y0,
  required double t0,
  required double tEnd,
  required double h,
  required int xIndex,
  required int yIndex,
  required int zIndex,
}) {
  return Isolate.run(
    () => computeScene(
      stepper: stepper,
      y0: y0,
      t0: t0,
      tEnd: tEnd,
      h: h,
      xIndex: xIndex,
      yIndex: yIndex,
      zIndex: zIndex,
    ),
  );
}
