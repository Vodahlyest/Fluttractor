/// Defines a record of three axes indices of a system in order
/// to build a 3d image of the trajectory
///
/// order of indices matters: (2, 0, 1) and (0, 1, 2) will result
/// in different images on screen
typedef ViewAxes = ({int axis1, int axis2, int axis3});

/// Checks if the selected triplet of axes is valid by three parameters:
/// 1. axes indices are not negative
/// 2. axes indices are strictly less than system's dimension (ref. Trajectory and OdeSystem)
/// 3. axes indices are not repeated
/// Argument error is thrown if at least one of the conditions is not
/// satisfied
void checkAxes(ViewAxes chosenTriplet, int dimension) {
  if (chosenTriplet.axis1 < 0 ||
      chosenTriplet.axis2 < 0 ||
      chosenTriplet.axis3 < 0) {
    throw ArgumentError(
      "One of the axis indices is negative: axis1: ${chosenTriplet.axis1}, axis2: ${chosenTriplet.axis2}, axis3: ${chosenTriplet.axis3}",
    );
  }
  if (chosenTriplet.axis1 >= dimension ||
      chosenTriplet.axis2 >= dimension ||
      chosenTriplet.axis3 >= dimension) {
    throw ArgumentError(
      "One of the axis indices is equal or greater than system's dimension: axis1: ${chosenTriplet.axis1}, axis2: ${chosenTriplet.axis2}, axis3: ${chosenTriplet.axis3}, dimension: $dimension",
    );
  }
  if (chosenTriplet.axis1 == chosenTriplet.axis2 ||
      chosenTriplet.axis1 == chosenTriplet.axis3 ||
      chosenTriplet.axis2 == chosenTriplet.axis3) {
    throw ArgumentError(
      "None of the axis indices should repeat: axis1: ${chosenTriplet.axis1}, axis2: ${chosenTriplet.axis2}, axis3: ${chosenTriplet.axis3}",
    );
  }
}
