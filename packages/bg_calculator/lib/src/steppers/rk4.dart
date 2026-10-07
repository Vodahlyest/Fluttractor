import 'stepper.dart';
import 'dart:typed_data';
import 'package:bg_calculator/src/vector_ops.dart';
import 'package:bg_calculator/src/ode_system.dart';

class Rk4 implements Stepper {
  Rk4({required this.system})
      : _k1Buff = Float64List(system.dimension),
        _k2Buff = Float64List(system.dimension),
        _k3Buff = Float64List(system.dimension),
        _k4Buff = Float64List(system.dimension),
        _tempBuff = Float64List(system.dimension);
  final OdeSystem system;
  final Float64List _k1Buff;
  final Float64List _k2Buff;
  final Float64List _k3Buff;
  final Float64List _k4Buff;
  final Float64List _tempBuff;

  @override
  int get order => 4;

  @override
  void step(double t, Float64List y, double h) {
    assert(
      y.length == system.dimension,
      "y vector length must match the dimension of the ODE system",
    );
    system.rhs(t, y, system.parameters, _k1Buff);
    axpy(y, h / 2.0, _k1Buff, _tempBuff);
    system.rhs(t + h/2.0, _tempBuff, system.parameters, _k2Buff);
    axpy(y, h / 2.0, _k2Buff, _tempBuff);
    system.rhs(t + h/2.0, _tempBuff, system.parameters, _k3Buff);
    axpy(y, h, _k3Buff, _tempBuff);
    system.rhs(t + h, _tempBuff, system.parameters, _k4Buff);
    for (int i = 0; i < y.length; i++) {
      y[i] += (h / 6.0) * (_k1Buff[i] + 2.0 * _k2Buff[i] + 2.0 * _k3Buff[i] + _k4Buff[i]);
    }
  }
}