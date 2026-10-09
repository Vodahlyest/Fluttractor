/// this library is used for all the calculations in the background
/// used for:
/// 1. numerical solving of ODE systems
/// other functions will be added later

//gotta be honest, i am really tired of wtinig all of this.
//dart is amazing, but OOP ingeneral is not the perfect choice
//for implementing math. Functional and procedural programming
//is more suitable for this kind of stuff.
//but still, it's still better than mixing 2 languages together LOL
library;

export 'src/ode_system.dart';
export 'src/systems/lorenz.dart';
export 'src/steppers/stepper.dart';
export 'src/steppers/explicit_euler.dart';
export 'src/steppers/rk4.dart';
export 'src/integrator.dart';
export 'src/trajectory.dart';
