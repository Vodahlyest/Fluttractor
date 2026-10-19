import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fluttractor/render/camera.dart';

void main() {
  test("no displacement", () {
    final Camera oldCam = (yaw: 0.0, pitch: 0.0);
    final newCam = orbit(oldCam, Offset(0.0, 0.0));
    expect(oldCam.yaw, equals(newCam.yaw));
    expect(oldCam.pitch, equals(newCam.pitch));
  });
  test("dx displaces only the yaw axis", () {
    final Camera oldCam = (yaw: 0.0, pitch: 0.0);
    final newCam = orbit(oldCam, Offset(1.0, 0.0));
    expect(oldCam.yaw, isNot(equals(newCam.yaw)));
    expect(oldCam.pitch, equals(newCam.pitch));
  });
  test("pitch axis is limited to +- pi / 2", () {
    final Camera oldCam = (yaw: 0.0, pitch: 0.0);
    final newCam = orbit(oldCam, Offset(15.0, 999.0));
    expect(newCam.pitch, equals(pi / 2));
  });
}
