import 'package:flutter/material.dart';

class Sizing {
  Sizing._();

  // Padding
  static const EdgeInsets paddingAll8 = EdgeInsets.all(8.0);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(16.0);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(24.0);
  static const EdgeInsets paddingSymmetricH24 = EdgeInsets.symmetric(horizontal: 24.0);
  
  // Border Radius
  static final BorderRadius allCircular16 = BorderRadius.circular(16.0);
  static final BorderRadius allCircular12 = BorderRadius.circular(12.0);

  // Spacing - Height
  static const SizedBox h8 = SizedBox(height: 8.0);
  static const SizedBox h16 = SizedBox(height: 16.0);
  static const SizedBox h24 = SizedBox(height: 24.0);
  static const SizedBox h32 = SizedBox(height: 32.0);
  
  // Spacing - Width
  static const SizedBox w8 = SizedBox(width: 8.0);
  static const SizedBox w16 = SizedBox(width: 16.0);
}
