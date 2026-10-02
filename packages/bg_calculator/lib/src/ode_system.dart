/// RightSide calculates the derivative f(t, y, p)
/// at one point.
/// dydt components must be fully filled
/// state and p must not be modified
typedef RightSide = void Function(
  double t,
  List<double> state,
  List<double> p,
  List<double> dydt,
);

/// OdeSystem describes the System of ODE, as the name suggests.
class OdeSystem {
  final List<String> variableNames;
  final List<String> parameterNames;
  final List<double> parameters;
  final RightSide rhs;

  OdeSystem({
    required List<String> variableNames,
    required List<String> parameterNames,
    required List<double> parameters,
    required this.rhs,
  }) : variableNames = List.unmodifiable(variableNames),
       parameterNames = List.unmodifiable(parameterNames),
       parameters = List.unmodifiable(parameters) {
    if (parameters.length != parameterNames.length) {
      throw ArgumentError(
        //something's wrong, hmmmmm.....
        "parameters: ${parameters.length}, parameter names: ${parameterNames.length}.",
      );
    }
    if (variableNames.isEmpty) {
      throw ArgumentError("please provide variables");
    }
    if (variableNames.toSet().length != variableNames.length) {
      throw ArgumentError("variables should be unique");
    }
    if (parameterNames.toSet().length != parameterNames.length) {
      throw ArgumentError("parameters should be unique");
    }
  }

  /// returns new system with only parameters changed
  /// original system does not change.
  OdeSystem withParameters(List<double> newParameters) {
    return OdeSystem(
      variableNames: variableNames,
      parameterNames: parameterNames,
      parameters: newParameters,
      rhs: rhs,
    );
  }

  int get dimension => variableNames.length;
}
