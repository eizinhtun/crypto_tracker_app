import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(fontSize: 14);

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
