import 'package:bg_calculator/bg_calculator.dart';

OdeSystem polynomialInit() {
  return OdeSystem(
    variableNames: ['y'],
    parameterNames: [],
    parameters: [],
    rhs: (t, state, p, dydt) {
      dydt[0] = 5 * (t * t * t * t);
    },
  );
}
