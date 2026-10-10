import 'package:bg_calculator/bg_calculator.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main(){
  late Trajectory lorenzTrajectory;
  setUpAll((){
    final y0 = Float64List.fromList([1, 1, 1]);
    final t0 = 0.0;
    final tEnd = 50.0;
    final h = 0.01;
    final method = Rk4(system: lorenz);
    lorenzTrajectory = integrate(method, y0, t0, tEnd, h);
  });

  test("state values are finite", (){
    expect(lorenzTrajectory.states.every((state) => state.isFinite), isTrue);
  });
  test("trajectory stays inside the bounding box", (){
    double xMin = double.infinity;
    double xMax = double.negativeInfinity;
    double yMin = double.infinity;
    double yMax = double.negativeInfinity;
    double zMin = double.infinity;
    double zMax = double.negativeInfinity;
    for(int i = 0; i < lorenzTrajectory.time.length; i++){
      xMin = lorenzTrajectory.stateAt(i)[0] < xMin ? lorenzTrajectory.stateAt(i)[0] : xMin;
      xMax = lorenzTrajectory.stateAt(i)[0] > xMax ? lorenzTrajectory.stateAt(i)[0] : xMax;
      yMin = lorenzTrajectory.stateAt(i)[1] < yMin ? lorenzTrajectory.stateAt(i)[1] : yMin;
      yMax = lorenzTrajectory.stateAt(i)[1] > yMax ? lorenzTrajectory.stateAt(i)[1] : yMax;
      zMin = lorenzTrajectory.stateAt(i)[2] < zMin ? lorenzTrajectory.stateAt(i)[2] : zMin;
      zMax = lorenzTrajectory.stateAt(i)[2] > zMax ? lorenzTrajectory.stateAt(i)[2] : zMax;
    }
    expect(xMin, inInclusiveRange(-30, 30));
    expect(xMax, inInclusiveRange(-30, 30));
    expect(yMin, inInclusiveRange(-40, 40));
    expect(yMax, inInclusiveRange(-40, 40));
    expect(zMin, inInclusiveRange(0, 60));
    expect(zMax, inInclusiveRange(0, 60));
  });
  test("chaos test (CHAOS, CHAOS! ©Jevil)", (){
    int signChange = 0;
    for(int i = 0; i < lorenzTrajectory.time.length - 1; i++){
      final currentState = lorenzTrajectory.stateAt(i);
      final nextState = lorenzTrajectory.stateAt(i+1);
      if((currentState[0] * nextState[0]).isNegative){
        signChange++;
      }
    }
    expect(signChange > 5, isTrue);
  });
}