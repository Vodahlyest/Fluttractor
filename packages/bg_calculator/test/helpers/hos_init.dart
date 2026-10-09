import 'package:bg_calculator/bg_calculator.dart';

OdeSystem systemInit(List<double> parameters) {
  return OdeSystem(
    variableNames: ['x', 'v'],
    parameterNames: ['Omega', 'F'],
    parameters: parameters,
    rhs: (double t, List<double> state, List<double> p, List<double> dydt) {
      final x = state[0];
      final v = state[1];
      final omega = p[0];
      final f = p[1];
      dydt[0] = v;
      dydt[1] = (-omega * omega) * x + f * t;
    },
  );
}
