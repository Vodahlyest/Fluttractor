import '../ode_system.dart';

/// this function evaluates the right-hand side of
/// equations in the Lorenz's system at the point
/// defined by state vector
///
/// dx/dt = sigma * (-x + y)
/// dy/dt = -(x * z) + (rho * x) - y
/// dz/dt = (x * y) - (beta * z)
///
/// state - variables in equations [x, y, z]
/// p - parameters in the equations [sigma, rho, beta]
/// t - time. Not used as Lorenz system's autonomous
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

/// Lorenz system with classic parameters
/// sigma = 10
/// rho = 28
/// beta = 8/3
final lorenz = OdeSystem(
  variableNames: ['x', 'y', 'z'],
  parameterNames: ['sigma', 'rho', 'beta'],
  parameters: [10, 28, 8 / 3],
  rhs: lorenzRhs,
);
