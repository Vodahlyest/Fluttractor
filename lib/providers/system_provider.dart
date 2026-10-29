import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_calculator/bg_calculator.dart';

final systemProvider = Provider<OdeSystem>((ref) => hyperchaoticRossler);
