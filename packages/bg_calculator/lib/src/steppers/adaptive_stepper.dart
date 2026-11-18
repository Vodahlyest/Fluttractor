import 'dart:typed_data';

import '../ode_system.dart';

/// Interface of the AdaptiveStepper object.
/// unlike the regular Stepper, its step method
/// takes two buffers: one for the prev. solution and one
/// for the next solution, along with the error estimate buffer
abstract interface class AdaptiveStepper {
  /// [t] - time of integration
  /// [h] - step size
  /// [y] - previous solution. Read only, after call - doesn't change
  /// [yNew] - following solution. same length as system's dimension
  /// [errorEstimate] - raw difference y_new - yHat_new, signed and no scaling
  ///
  /// [yNew] and [errorEstimate] should not be the same object
  void step(
    double t,
    Float64List y,
    double h,
    Float64List yNew,
    Float64List errorEstimate,
  );

  /// Order of the outer method
  int get order;

  /// Order of the inner method, which is used to estimate error
  /// (example for DOPRI5, errorOrder == 4)
  int get errorOrder;

  OdeSystem get system;
}
