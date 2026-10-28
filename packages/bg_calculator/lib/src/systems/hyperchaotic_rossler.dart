import '../ode_system.dart';

/// right-hand side of Hyperchaotic Rossler's ODE system
///
/// dx/dt = -y -z
/// dy/dt = x + a*y + w
/// dz/dt = b + x*z
/// dw/dt = -c*z + d*w
///
/// guarantees:
/// - no extra memory is allocated, due to the result buffer being passed as an
/// argument
///
/// [t] - time of derivation. Not used as rösslers system is autonomous
/// [state] - current state at the time [t]
/// [p] - parameters of the system
/// [dydt] - result buffer, stores derivatives for all variables at time [t]
///
/// ref. to the Rossler's work: Rössler O. E., An equation for hyperchaos, Physics Letters A, 1979, Vol. 71, P. 155–157.
void hyperchaoticRosslerRhs(
  double t,
  List<double> state,
  List<double> p,
  List<double> dydt,
) {
  final x = state[0];
  final y = state[1];
  final z = state[2];
  final w = state[3];

  final a = p[0];
  final b = p[1];
  final c = p[2];
  final d = p[3];

  //order: dx/dt, dy/dt, dz/dt, dw/dt
  dydt[0] = -y - z;
  dydt[1] = x + (a * y) + w;
  dydt[2] = b + (x * z);
  dydt[3] = (-c * z) + (d * w);
}

/// hyperchaotic Rossler's system with parameters:
/// a = 0.25, b = 3, c = 0.5, d = 0.05
final hyperchaoticRossler = OdeSystem(
  variableNames: ['x', 'y', 'z', 'w'],
  parameterNames: ['a', 'b', 'c', 'd'],
  parameters: [0.25, 3, 0.5, 0.05],
  rhs: hyperchaoticRosslerRhs,
);
