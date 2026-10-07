import 'dart:typed_data';

/// interface of a Stepper object. Contract implies having
/// 1. a step function that takes in the current time, the current state vector, and the step size
/// 2. an order property that returns the order of the method
/// such implementation is suitable for using different ODE system solvers
/// does not return a new y vector. the given y is rewritten right in the step
abstract interface class Stepper {
  /// y has length of ODE system's dimension.
  /// y at time t is passed
  /// y at time t+h is rewritten to y
  void step(double t, Float64List y, double h);

  /// returns the order of the method.
  int get order;
}
