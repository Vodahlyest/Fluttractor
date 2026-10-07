/// this library is used for all the calculations in the background
/// used for:
/// 1. numerical solving of ODE systems
/// other functions will be added later

library;

export 'src/ode_system.dart';
export 'src/systems/lorenz.dart';
export 'src/steppers/stepper.dart';
export 'src/steppers/explicit_euler.dart';
export 'src/steppers/rk4.dart';
