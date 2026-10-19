import 'package:flutter/material.dart';

import 'dart:math';

typedef Camera = ({double yaw, double pitch});

Camera orbit(Camera camera, Offset delta, {double sensitivity = 0.01}) {
  final Camera newCam = (
    yaw: camera.yaw + (delta.dx * sensitivity),
    pitch: (camera.pitch + (delta.dy * sensitivity))
        .clamp(-pi / 2, pi / 2)
        .toDouble(),
  );
  return newCam;
}
