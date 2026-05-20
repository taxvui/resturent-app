import 'package:flutter/material.dart';

extension ResponsiveCardExt on Size {
  bool get isTn => width > 0 && width < 375;
  bool get isSm => width >= 375 && width < 640;
  bool get isMd => width >= 640 && width < 1024;
  bool get isLg => width >= 1024 && width < 1440;
  bool get isXl => width >= 1440;
}
