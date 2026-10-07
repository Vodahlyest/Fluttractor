import 'dart:typed_data';

import 'stepper.dart';
import '../vector_ops.dart';
import '../ode_system.dart';

class ExplicitEuler implements Stepper {
  ExplicitEuler({required this.system})
    : _kBuff = Float64List(system.dimension);

  final OdeSystem system;
  final Float64List _kBuff;
  @override
  int get order => 1;

  @override
  void step(double t, Float64List y, double h) {
    assert(
      y.length == system.dimension,
      "y vector length must match the dimension of the ODE system: y length: ${y.length}, system dimension: ${system.dimension}",
    );
    system.rhs(t, y, system.parameters, _kBuff);
    axpy(y, h, _kBuff, y);
  }
}
