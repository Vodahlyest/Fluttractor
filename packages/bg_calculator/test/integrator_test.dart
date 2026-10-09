import 'dart:typed_data';
import 'dart:math';

import 'package:test/test.dart';
import 'package:bg_calculator/bg_calculator.dart';

import 'helpers/hos_init.dart';

void main() {
  test("main integrator test", () {
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = Rk4(system: system);
    final trajectory = integrate(method, y0, 0, 1, 0.1);
    final pointIndex1 = 1;
    final pointIndex2 = 3;
    expect(trajectory.points, equals(11));
    expect(trajectory.time[0], equals(0));
    expect(trajectory.time[10], closeTo(1.0, 1e-12));
    expect(trajectory.time[pointIndex1], closeTo(pointIndex1 * 0.1, 1e-12));
    expect(trajectory.time[pointIndex2], closeTo(pointIndex2 * 0.1, 1e-12));
  });
  test("integrator adapts to different step values", () {
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = Rk4(system: system);
    final trajectory = integrate(method, y0, 0, 1, 0.3);
    expect(trajectory.points, equals(5));
    expect(trajectory.time[1], closeTo(0.25, 1e-12));
    expect(trajectory.time[4], closeTo(1, 1e-12));
  });
  test("y0 does not change after integration", () {
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final yCopy = Float64List.fromList(y0);
    final method = Rk4(system: system);
    final trajectory = integrate(method, y0, 0, 1, 0.3);
    expect(trajectory.stateAt(0), equals(yCopy));
    expect(yCopy, equals(y0));
  });
  test("points are independent", () {
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = Rk4(system: system);
    final trajectory = integrate(method, y0, 0, 1, 0.3);
    expect(trajectory.stateAt(0), isNot(equals(trajectory.stateAt(4))));
  });
  test("accuracy test", () {
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = Rk4(system: system);
    final trajectory = integrate(method, y0, 0, 1, 0.01);
    final timePoint = trajectory.time[trajectory.time.length - 1];
    final x_t =
        y0[0] * cos(system.parameters[0] * timePoint) +
        (y0[1] / system.parameters[0]) * sin(system.parameters[0] * timePoint);
    final v_t =
        y0[1] * cos(system.parameters[0] * timePoint) -
        y0[0] * system.parameters[0] * sin(system.parameters[0] * timePoint);
    expect(
      trajectory.stateAt(trajectory.time.length - 1)[0],
      closeTo(x_t, 1e-7),
    );
    expect(
      trajectory.stateAt(trajectory.time.length - 1)[1],
      closeTo(v_t, 1e-7),
    );
  });
  test("accuracy test: omega = 0", () {
    final system = systemInit([0, 5]);
    final y0 = Float64List.fromList([2, -3]);
    final method = Rk4(system: system);
    final trajectory = integrate(method, y0, 0.5, 1.5, 0.1);
    final x_t =
        y0[0] +
        (y0[1] * (1.5 - 0.5)) +
        system.parameters[1] *
            ((((1.5 * 1.5 * 1.5) - (0.5 * 0.5 * 0.5)) / 6) -
                ((0.5 * 0.5) * ((1.5 - 0.5) / 2)));
    final v_t =
        y0[1] + (system.parameters[1] * ((1.5 * 1.5) - (0.5 * 0.5)) / 2);
    expect(
      trajectory.stateAt(trajectory.time.length - 1)[0],
      closeTo(x_t, 1e-12),
    );
    expect(
      trajectory.stateAt(trajectory.time.length - 1)[1],
      closeTo(v_t, 1e-12),
    );
  });
  test("accuracy test: euler's method", () {
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = ExplicitEuler(system: system);
    final trajectory = integrate(method, y0, 0, 1, 0.00001);
    expect(trajectory.points, equals(100001));
    final timePoint = trajectory.time[trajectory.time.length - 1];
    final x_t =
        y0[0] * cos(system.parameters[0] * timePoint) +
        (y0[1] / system.parameters[0]) * sin(system.parameters[0] * timePoint);
    final v_t =
        y0[1] * cos(system.parameters[0] * timePoint) -
        y0[0] * system.parameters[0] * sin(system.parameters[0] * timePoint);
    expect(
      trajectory.stateAt(trajectory.time.length - 1)[0],
      closeTo(x_t, 1e-3),
    );
    expect(
      trajectory.stateAt(trajectory.time.length - 1)[1],
      closeTo(v_t, 1e-3),
    );
  });
}
