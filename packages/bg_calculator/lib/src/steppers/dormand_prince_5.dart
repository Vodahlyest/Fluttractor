import 'dart:typed_data';

import 'package:bg_calculator/src/vector_ops.dart';

import 'package:bg_calculator/src/steppers/dormand_prince_tableau.dart';
import 'package:bg_calculator/src/steppers/adaptive_stepper.dart';

import '../ode_system.dart';

class DormandPrince5 implements AdaptiveStepper {
  DormandPrince5({required this.system})
    : _kiBuffers = List.generate(
        dpC.length,
        (count) => Float64List(system.dimension),
      ),
      _tempBuff = Float64List(system.dimension);

  @override
  final OdeSystem system;
  final Float64List _tempBuff;
  final List<Float64List> _kiBuffers;

  @override
  void step(
    double t,
    Float64List y,
    double h,
    Float64List yNew,
    Float64List errorEstimate,
  ) {
    assert(
      y.length == system.dimension &&
          yNew.length == system.dimension &&
          errorEstimate.length == system.dimension,
      "lengths of y, yNew and errorEstimate should be equal to systems dimension: y: ${y.length}, yNew: ${yNew.length}, errorEstimate: ${errorEstimate.length}",
    );
    assert(
      !identical(yNew, y) && !identical(errorEstimate, y),
      "yNew and errorEstimate should be different from y objects",
    );

    for (int i = 0; i < dpC.length; i++) {
      _tempBuff.setRange(0, y.length, y);
      for (int j = 0; j < i; j++) {
        axpy(_tempBuff, h * dpA[i][j], _kiBuffers[j], _tempBuff);
      }
      system.rhs(t + dpC[i] * h, _tempBuff, system.parameters, _kiBuffers[i]);
    }

    yNew.setRange(0, y.length, y);
    for (int i = 0; i < dpC.length; i++) {
      axpy(yNew, h * dpB[i], _kiBuffers[i], yNew);
    }
    errorEstimate.fillRange(0, errorEstimate.length, 0);
    for (int i = 0; i < dpC.length; i++) {
      axpy(
        errorEstimate,
        h * (dpB[i] - dpBHat[i]),
        _kiBuffers[i],
        errorEstimate,
      );
    }
  }

  @override
  int get order => 5;

  @override
  int get errorOrder => 4;
}
