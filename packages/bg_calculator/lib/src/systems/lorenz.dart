/// this is the Lorenz attractor model implemented in dart form
/// using OdeSystem class and RightSide typedef
/// declared in src/ode_system.dart
/// 
/// dx/dt = \sigma * (-x + y)
/// dy/dt = -(x * z) + (\rho * x) - y
/// dz/dt = (x * y) - (beta * z)
import '../ode_system.dart';

void lorenzRhs(
  double t,
  List<double> state,
  List<double> p,
  List<double> dydt,
) {
  final x = state[0];
  final y = state[1];
  final z = state[2];

  final sigma = p[0];
  final rho = p[1];
  final beta = p[2];

  dydt[0] = sigma * (-x + y);
  dydt[1] = -(x * z) + (rho * x) - y;
  dydt[2] = (x * y) - (beta * z);
}

final lorenz = OdeSystem(
  variableNames: ['x', 'y', 'z'], 
  parameterNames: ['sigma', 'rho', 'beta'], 
  parameters: [10, 28, 8/3], 
  rhs: lorenzRhs
);
