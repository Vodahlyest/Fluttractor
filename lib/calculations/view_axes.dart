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
      "One of the axis indices is negative: "
      "axis1: ${chosenTriplet.axis1}, axis2: ${chosenTriplet.axis2}, axis3: ${chosenTriplet.axis3}",
    );
  }
  if (chosenTriplet.axis1 >= dimension ||
      chosenTriplet.axis2 >= dimension ||
      chosenTriplet.axis3 >= dimension) {
    throw ArgumentError(
      "One of the axis indices is equal or greater than system's dimension: "
      "axis1: ${chosenTriplet.axis1}, axis2: ${chosenTriplet.axis2}, axis3: ${chosenTriplet.axis3}, dimension: $dimension",
    );
  }
  if (chosenTriplet.axis1 == chosenTriplet.axis2 ||
      chosenTriplet.axis1 == chosenTriplet.axis3 ||
      chosenTriplet.axis2 == chosenTriplet.axis3) {
    throw ArgumentError(
      "None of the axis indices should repeat: "
      "axis1: ${chosenTriplet.axis1}, axis2: ${chosenTriplet.axis2}, axis3: ${chosenTriplet.axis3}",
    );
  }
}

/// Allows to set new axis at new position for building new projection
/// primarily used for working with systems where n (dimensions) > 3
///
/// - [axisNumber] is specified as the actual number of axis in ViewAxes,
/// i.e 1, 2, 3.
/// - if specified axis index and position are matching the original triplet,
/// the original triplet is returned
/// - if specified axis index is already in the original triplet under
/// another position, axis index under desired position and desired axis index
/// under another position are swapped placed
/// - other cases result in new triplet with new axis index at desired
/// place
ViewAxes setAxesWithParameters(
  ViewAxes currentTriplet,
  int axisNumber,
  int axisIndex,
) {
  if (!(1 <= axisNumber && axisNumber <= 3)) {
    throw ArgumentError("axis number should be in range of [1;3]: $axisNumber");
  }
  final (axis1: currentAxis1, axis2: currentAxis2, axis3: currentAxis3) =
      currentTriplet;
  final tripletList = [currentAxis1, currentAxis2, currentAxis3];
  final old = tripletList[axisNumber - 1];
  final other = tripletList.indexOf(axisIndex);
  if (other == (axisNumber - 1)) {
    return currentTriplet;
  } else if (other != -1) {
    tripletList[other] = old;
  }
  tripletList[axisNumber - 1] = axisIndex;
  return (axis1: tripletList[0], axis2: tripletList[1], axis3: tripletList[2]);
}
