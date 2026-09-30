import 'package:test/test.dart';
import 'package:bg_calculator/bg_calculator.dart';

void main() {
  group('correct system works', () {
    test('dimension is equal to the amount of passed variables', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      OdeSystem testSystem = OdeSystem(
        variableNames: <String>['x', 'y', 'z'],
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: rhsFunction,
      );
      expect(testSystem.dimension, equals(3));
    });
  });
  group('incorrect systems', () {
    test('no variables provided', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      expect(
        () => OdeSystem(
          variableNames: <String>[],
          parameterNames: <String>['sigma', 'rho', 'beta'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: rhsFunction,
        ),
        throwsArgumentError,
      );
    });
    test('parameter values don`t match the amount of parameter names', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      expect(
        () => OdeSystem(
          variableNames: <String>['x', 'y', 'z'],
          parameterNames: <String>['sigma', 'rho'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: rhsFunction,
        ),
        throwsArgumentError,
      );
    });
    test('non-unique variables don`t pass', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      expect(
        () => OdeSystem(
          variableNames: <String>['x', 'y', 'y'],
          parameterNames: <String>['sigma', 'rho', 'beta'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: rhsFunction,
        ),
        throwsArgumentError,
      );
    });
    test('non-unique param-s don`t pass', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      expect(
        () => OdeSystem(
          variableNames: <String>['x', 'y', 'z'],
          parameterNames: <String>['sigma', 'rho', 'rho'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: rhsFunction,
        ),
        throwsArgumentError,
      );
    });
  });
  group('immutability check', () {
    test('.add for variables throws error', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      OdeSystem testSystem = OdeSystem(
        variableNames: <String>['x', 'y', 'z'],
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: rhsFunction,
      );
      expect(() => testSystem.variableNames.add('w'), throwsUnsupportedError);
    });
    test('.add for parameters throws', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      OdeSystem testSystem = OdeSystem(
        variableNames: <String>['x', 'y', 'z'],
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: rhsFunction,
      );
      expect(
        () => testSystem.parameterNames.add('alpha'),
        throwsUnsupportedError,
      );
      expect(() => testSystem.parameters.add(5.0), throwsUnsupportedError);
    });
    test('protected copy', () {
      RightSide rhsFunction = (t, y, p, dydt) {};
      List<String> separateVariables = ['x', 'y', 'z'];
      OdeSystem testSystem = OdeSystem(
        variableNames: separateVariables,
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: rhsFunction,
      );
      separateVariables.add('w');
      expect(testSystem.variableNames, equals(['x', 'y', 'z']));
    });
  });
}
