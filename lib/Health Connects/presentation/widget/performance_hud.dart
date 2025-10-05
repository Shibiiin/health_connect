import 'dart:ui';

import 'package:flutter/material.dart';

class PerformanceHud extends StatelessWidget {
  final String buildTimeMs;
  final String fps;

  const PerformanceHud({
    super.key,
    required this.buildTimeMs,
    required this.fps,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed, color: Colors.white.withOpacity(0.7), size: 12),
              const SizedBox(width: 6),
              Text(
                'build: $buildTimeMs, fps: $fps',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
