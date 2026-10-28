import 'dart:typed_data';

import 'package:bg_calculator/bg_calculator.dart';
import 'package:test/test.dart';

void main() {
  test("hyperchaotic rossler's rhs calculates derivatives right", () {
    final dydt = [0.0, 0.0, 0.0, 0.0];
    final state = [1.0, 2.0, 3.0, 4.0];
    hyperchaoticRossler.rhs(1.0, state, hyperchaoticRossler.parameters, dydt);
    /*
      dydt[0] = -y - z;
      dydt[1] = x + (a * y) + w;
      dydt[2] = b + (x * z);
      dydt[3] = (-c * z) + (d * w);
     */
    final expectedDxDt = -5.0;
    final expectedDyDt = 5.5;
    final expectedDzDt = 6.0;
    final expectedDwDt = -1.3;

    expect(dydt[0], closeTo(expectedDxDt, 1e-12));
    expect(dydt[1], closeTo(expectedDyDt, 1e-12));
    expect(dydt[2], closeTo(expectedDzDt, 1e-12));
    expect(dydt[3], closeTo(expectedDwDt, 1e-12));
  });
  test("dimensions and names", () {
    expect(hyperchaoticRossler.parameters[0], equals(0.25));
    expect(hyperchaoticRossler.parameters[1], equals(3.0));
    expect(hyperchaoticRossler.parameters[2], equals(0.5));
    expect(hyperchaoticRossler.parameters[3], equals(0.05));
    expect(hyperchaoticRossler.parameterNames[0], equals("a"));
    expect(hyperchaoticRossler.parameterNames[1], equals("b"));
    expect(hyperchaoticRossler.parameterNames[2], equals("c"));
    expect(hyperchaoticRossler.parameterNames[3], equals("d"));
    expect(hyperchaoticRossler.variableNames[0], equals("x"));
    expect(hyperchaoticRossler.variableNames[1], equals("y"));
    expect(hyperchaoticRossler.variableNames[2], equals("z"));
    expect(hyperchaoticRossler.variableNames[3], equals("w"));
    expect(hyperchaoticRossler.dimension, equals(4));
  });
  test(
    "system's trajectory values are finite and enclosed within certain area",
    () {
      final trajectory = integrate(
        Rk4(system: hyperchaoticRossler),
        Float64List.fromList([-10.0, -6.0, 0.0, 10]),
        0,
        200,
        0.01,
      );
      expect(trajectory.states.every((value) => value.isFinite), isTrue);
      expect(trajectory.states.every((value) => value.abs() < 500), isTrue);
    },
  );
}
