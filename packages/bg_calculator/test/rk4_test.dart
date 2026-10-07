import 'package:test/test.dart';
import 'package:bg_calculator/bg_calculator.dart';
import 'dart:math';
import 'dart:typed_data';

void main(){
  late OdeSystem Function(List<double>) systemInit;
  setUp(() {
    systemInit = (List<double> parameters) {
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
    };
  });

  test("rk4 accuracy test, F = 0", (){
    final hos = systemInit([2.0, 0.0]);
    final stepper = Rk4(system: hos);
    final state = Float64List.fromList([2.0, -3.0]);
    final h = 0.1;
    final t = 0.0;
    final x = state[0] * cos(hos.parameters[0] * (t + h)) + (state[1] / hos.parameters[0]) * sin(hos.parameters[0] * (t + h));
    final v = state[1] * cos(hos.parameters[0] * (t + h)) - hos.parameters[0] * state[0] * sin(hos.parameters[0] * (t + h));
    stepper.step(t, state, h);
    expect(state[0], closeTo(x, 1e-5));
    expect(state[1], closeTo(v, 1e-4));
  });
  test("rk4 accuracy test, F = 5", (){
    final hos = systemInit([0.0, 5.0]);
    final stepper = Rk4(system: hos);
    final state = Float64List.fromList([2.0, -3.0]);
    final h = 0.1;
    final t = 0.5;
    final tNew = t+h;
    final vNew = state[1] + hos.parameters[1]*((tNew*tNew) - (t*t)) / 2;
    final xNew = state[0] + (state[1]*h) + hos.parameters[1]*(((tNew*tNew*tNew) - (t*t*t))/6 - (t*t)*h/2);
    stepper.step(t, state, h);
    expect(state[0], closeTo(xNew, 1e-12));
    expect(state[1], closeTo(vNew, 1e-12));
  });
  test("assertion error test", (){
    final hos = systemInit([0.0, 5.0]);
    final stepper = Rk4(system: hos);
    final state = Float64List.fromList([2.0]);
    final h = 0.1;
    final t = 0.5;
    expect(() => stepper.step(t, state, h), throwsA(isA<AssertionError>()));
  });
  test("order returns 4 for rk", (){
    final hos = systemInit([0.0, 5.0]);
    final stepper = Rk4(system: hos);
    expect(stepper.order, equals(4));
  });
}