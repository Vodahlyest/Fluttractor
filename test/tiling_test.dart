import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttractor/features/viewer/tiling.dart';
import 'package:fluttractor/constant_values/view_limit.dart';

void main() {
  group("layout geometry tests", () {
    test("1 view, correct layout geometry", () {
      final rects = buildTiles(1, Size(800, 600), gap: 0);
      expect(rects, equals([Rect.fromLTWH(0, 0, 800, 600)]));
    });
    test("2 views, correct wide layout geometry", () {
      final rects = buildTiles(2, Size(800, 600), gap: 0);
      expect(
        rects,
        equals([
          Rect.fromLTWH(0, 0, 400, 600),
          Rect.fromLTWH(400, 0, 400, 600),
        ]),
      );
    });
    test("2 views, correct vertical layout geometry", () {
      final rects = buildTiles(2, Size(600, 800), gap: 0);
      expect(
        rects,
        equals([
          Rect.fromLTWH(0, 0, 600, 400),
          Rect.fromLTWH(0, 400, 600, 400),
        ]),
      );
    });
    test("3 views, correct horizontal layout geometry", () {
      final rects = buildTiles(3, Size(800, 600), gap: 0);
      expect(
        rects,
        equals([
          Rect.fromLTWH(0, 0, 400, 600),
          Rect.fromLTWH(400, 0, 400, 300),
          Rect.fromLTWH(400, 300, 400, 300),
        ]),
      );
    });
    test("3 views, correct vertical layout geometry", () {
      final rects = buildTiles(3, Size(600, 800), gap: 0);
      expect(
        rects,
        equals([
          Rect.fromLTWH(0, 0, 600, 400),
          Rect.fromLTWH(0, 400, 300, 400),
          Rect.fromLTWH(300, 400, 300, 400),
        ]),
      );
    });
    test("4 views, correct layout geometry", () {
      final rects = buildTiles(4, Size(800, 600), gap: 0);
      expect(
        rects,
        equals([
          Rect.fromLTWH(0, 0, 400, 300),
          Rect.fromLTWH(400, 0, 400, 300),
          Rect.fromLTWH(0, 300, 400, 300),
          Rect.fromLTWH(400, 300, 400, 300),
        ]),
      );
    });
    test("square screen gives horizontal layout", () {
      final rects = buildTiles(2, Size(600, 600), gap: 0);
      expect(
        rects,
        equals([
          Rect.fromLTWH(0, 0, 300, 600),
          Rect.fromLTWH(300, 0, 300, 600),
        ]),
      );
    });
  });
  group("properties tests", () {
    // screen sizes and the amount of views
    final testOptions = [
      (Size(800, 600), 1),
      (Size(800, 600), 2),
      (Size(800, 600), 3),
      (Size(800, 600), 4),
      (Size(600, 800), 1),
      (Size(600, 800), 2),
      (Size(600, 800), 3),
      (Size(600, 800), 4),
      (Size(600, 600), 1),
      (Size(600, 600), 2),
      (Size(600, 600), 3),
      (Size(600, 600), 4),
    ];
    for (int i = 0; i < testOptions.length; i++) {
      test("result's length equals to number of views", () {
        final rects = buildTiles(testOptions[i].$2, testOptions[i].$1, gap: 0);
        expect(rects.length, equals(testOptions[i].$2));
      });
      test("rectangles are in the specified area", () {
        final rects = buildTiles(testOptions[i].$2, testOptions[i].$1, gap: 0);
        for (int j = 0; j < rects.length; j++) {
          expect(rects[j].left, greaterThanOrEqualTo(0));
          expect(rects[j].top, greaterThanOrEqualTo(0));
          expect(rects[j].right, lessThanOrEqualTo(testOptions[i].$1.width));
          expect(rects[j].bottom, lessThanOrEqualTo(testOptions[i].$1.height));
        }
      });
      test("rectangles are not overlapping", () {
        final rects = buildTiles(testOptions[i].$2, testOptions[i].$1, gap: 0);
        for (int j = 0; j < rects.length - 1; j++) {
          for (int f = j + 1; f < rects.length; f++) {
            expect(rects[j].overlaps(rects[f]), isFalse);
          }
        }
      });
      test("sum of all areas equals to screen's area", () {
        final rects = buildTiles(testOptions[i].$2, testOptions[i].$1, gap: 0);
        double areas = 0;
        for (int j = 0; j < rects.length; j++) {
          areas += rects[j].width * rects[j].height;
        }
        expect(
          areas,
          equals(testOptions[i].$1.width * testOptions[i].$1.height),
        );
      });
    }
  });
  group("gap tests", () {
    final testOptions = [
      (Size(800, 600), 1),
      (Size(800, 600), 2),
      (Size(800, 600), 3),
      (Size(800, 600), 4),
      (Size(600, 800), 1),
      (Size(600, 800), 2),
      (Size(600, 800), 3),
      (Size(600, 800), 4),
      (Size(600, 600), 1),
      (Size(600, 600), 2),
      (Size(600, 600), 3),
      (Size(600, 600), 4),
    ];
    for (int i = 0; i < testOptions.length; i++) {
      test("gapped rects after inflation equal to rects without gaps", () {
        final inflatedRects = buildTiles(
          testOptions[i].$2,
          testOptions[i].$1,
          gap: 0,
        );
        final deflatedRects = buildTiles(
          testOptions[i].$2,
          testOptions[i].$1,
          gap: 8,
        );
        for (int j = 0; j < deflatedRects.length; j++) {
          expect(deflatedRects[j].inflate(4), equals(inflatedRects[j]));
        }
      });
    }
    test("specific values", () {
      final rects = buildTiles(2, Size(800, 600), gap: 8);
      expect(rects.first, equals(Rect.fromLTWH(4, 4, 392, 592)));
      expect(rects.last, equals(Rect.fromLTWH(404, 4, 392, 592)));
    });
    test("default value for gap", () {
      final rects = buildTiles(1, Size(800, 600));
      expect(rects.last, equals(Rect.fromLTWH(2, 2, 796, 596)));
    });
  });
  group("errors tests", () {
    test("0 views -> argument error", () {
      expect(() => buildTiles(0, Size(800, 600)), throwsArgumentError);
    });
    test("viewLimit + 1 views -> argument error", () {
      expect(
        () => buildTiles(viewLimit + 1, Size(800, 600)),
        throwsArgumentError,
      );
    });
    test("-1 view -> argument error", () {
      expect(() => buildTiles(-1, Size(800, 600)), throwsArgumentError);
    });
  });
}
