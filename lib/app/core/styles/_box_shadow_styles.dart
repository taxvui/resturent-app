import 'package:flutter/material.dart';

abstract class DAppBoxShadowStyles {
  static final boxShadow1 = BoxShadow(
    color: const Color(0xff949494).withValues(alpha: 0.2),
    offset: const Offset(0, 14),
    blurRadius: 60,
    spreadRadius: 0,
  );
  static final boxShadow2 = BoxShadow(
      color: const Color(0xff473232).withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 1),
      spreadRadius: -1);
  static final boxShadow3 = BoxShadow(
      color: const Color(0xff0c1a4b).withValues(alpha: 0.02),
      offset: const Offset(0, 0),
      blurRadius: 1,
      spreadRadius: 0);
}
