import 'package:test/test.dart';
import 'package:bg_calculator/bg_calculator.dart';

void main() {
  group('correct system works', () {
    test('dimension is equal to the amount of passed variables', () {
      OdeSystem testSystem = OdeSystem(
        variableNames: <String>['x', 'y', 'z'],
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: (t, y, p, dydt) {}
      );
      expect(testSystem.dimension, equals(3));
    });
  });
  group('incorrect systems', () {
    test('no variables provided', () {
      expect(
        () => OdeSystem(
          variableNames: <String>[],
          parameterNames: <String>['sigma', 'rho', 'beta'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: (t, y, p, dydt) {},
        ),
        throwsArgumentError,
      );
    });
    test('parameter values don`t match the amount of parameter names', () {
      expect(
        () => OdeSystem(
          variableNames: <String>['x', 'y', 'z'],
          parameterNames: <String>['sigma', 'rho'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: (t, y, p, dydt) {},
        ),
        throwsArgumentError,
      );
    });
    test('non-unique variables don`t pass', () {
      expect(
        () => OdeSystem(
          variableNames: <String>['x', 'y', 'y'],
          parameterNames: <String>['sigma', 'rho', 'beta'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: (t, y, p, dydt) {},
        ),
        throwsArgumentError,
      );
    });
    test('non-unique param-s don`t pass', () {
      expect(
        () => OdeSystem(
          variableNames: <String>['x', 'y', 'z'],
          parameterNames: <String>['sigma', 'rho', 'rho'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: (t, y, p, dydt) {},
        ),
        throwsArgumentError,
      );
    });
  });
  group('immutability check', () {
    test('.add for variables throws error', () {
      OdeSystem testSystem = OdeSystem(
        variableNames: <String>['x', 'y', 'z'],
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: (t, y, p, dydt) {},
      );
      expect(() => testSystem.variableNames.add('w'), throwsUnsupportedError);
    });
    test('.add for parameters throws', () {
      OdeSystem testSystem = OdeSystem(
        variableNames: <String>['x', 'y', 'z'],
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: (t, y, p, dydt) {},
      );
      expect(
        () => testSystem.parameterNames.add('alpha'),
        throwsUnsupportedError,
      );
      expect(() => testSystem.parameters.add(5.0), throwsUnsupportedError);
    });
    test('protected copy', () {
      List<String> separateVariables = ['x', 'y', 'z'];
      OdeSystem testSystem = OdeSystem(
        variableNames: separateVariables,
        parameterNames: <String>['sigma', 'rho', 'beta'],
        parameters: <double>[10.0, 28.0, 8 / 3],
        rhs: (t, y, p, dydt) {},
      );
      separateVariables.add('w');
      expect(testSystem.variableNames, equals(['x', 'y', 'z']));
    });
  });
  group("WithParameters test", () {
    test(
      "new system with the new set of parameters, other fields are the same",
      () {
        OdeSystem test1 = OdeSystem(
          variableNames: ['x', 'y', 'z'],
          parameterNames: <String>['sigma', 'rho', 'beta'],
          parameters: <double>[10.0, 28.0, 8 / 3],
          rhs: (t, y, p, dydt) {},
        );
        //average math metal beta parameter be like:
        OdeSystem test2 = test1.withParameters([1, 54, 7 / 8]);
        expect(test1.parameters, equals([10.0, 28.0, 8 / 3]));
        expect(test2.parameters, equals([1, 54, 7 / 8]));
        expect(test2.variableNames, equals(test1.variableNames));
        expect(test2.rhs, same(test1.rhs));
        expect(() => test1.withParameters([]), throwsArgumentError);
      },
    );
  });
}
