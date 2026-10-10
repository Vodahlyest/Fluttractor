import 'package:bg_calculator/bg_calculator.dart';
import 'helpers/accurate_solution.dart';
import 'helpers/hos_init.dart';
import 'package:test/test.dart';
import 'dart:typed_data';
import 'dart:math';

void main(){
  test("main convergence test: rk4", (){
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = Rk4(system: system);
    final trajectory1 = integrate(method, y0, 0, 1, 0.1);
    final trajectory2 = integrate(method, y0, 0, 1, 0.05);
    final trajectory3 = integrate(method, y0, 0, 1, 0.025);
    final correctSolve = correctSolution(y0, system, trajectory1.time[trajectory1.time.length - 1]);
    final error1 = (trajectory1.stateAt(trajectory1.time.length - 1)[0] - correctSolve[0]).abs();
    final error2 = (trajectory2.stateAt(trajectory2.time.length - 1)[0] - correctSolve[0]).abs();
    final error3 = (trajectory3.stateAt(trajectory3.time.length - 1)[0] - correctSolve[0]).abs();
    final obsOrder1 = log(error1 / error2) / ln2;
    final obsOrder2 = log(error2 / error3) / ln2;
    expect(obsOrder1, inInclusiveRange(3.7, 4.3));
    expect(obsOrder2, inInclusiveRange(3.7, 4.3));
  });
  test("main convegence test: euler", (){
    final system = systemInit([2, 0]);
    final y0 = Float64List.fromList([2, -3]);
    final method = ExplicitEuler(system: system);
    final trajectory1 = integrate(method, y0, 0, 1, 0.1);
    final trajectory2 = integrate(method, y0, 0, 1, 0.05);
    final trajectory3 = integrate(method, y0, 0, 1, 0.025);
    final correctSolve = correctSolution(y0, system, trajectory1.time[trajectory1.time.length - 1]);
    final error1 = (trajectory1.stateAt(trajectory1.time.length - 1)[0] - correctSolve[0]).abs();
    final error2 = (trajectory2.stateAt(trajectory2.time.length - 1)[0] - correctSolve[0]).abs();
    final error3 = (trajectory3.stateAt(trajectory3.time.length - 1)[0] - correctSolve[0]).abs();
    final obsOrder1 = log(error1 / error2) / ln2;
    final obsOrder2 = log(error2 / error3) / ln2;
    expect(obsOrder1, inInclusiveRange(0.9, 1.1));
    expect(obsOrder2, inInclusiveRange(0.9, 1.1));
  });
}