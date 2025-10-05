import 'package:flutter/material.dart';

class InfoCardModal {
  final String title;
  final String value;
  final String? subValue;
  final IconData icon;
  final Gradient gradient;
  InfoCardModal({
    required this.title,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.gradient,
  });
}
