import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repository/health_repository.dart';
import '../routes/app_routes.dart';

class HealthSplashScreen extends StatefulWidget {
  const HealthSplashScreen({super.key});

  @override
  HealthSplashScreenState createState() => HealthSplashScreenState();
}

class HealthSplashScreenState extends State<HealthSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _walkingAnimation;
  late Animation<double> _heartbeatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _walkingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0, curve: _HeartbeatCurve()),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(Duration(seconds: 2), () {
      checkPermissionsAndNavigate(context);
    });
  }

  Future<void> checkPermissionsAndNavigate(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    final healthRepo = HealthRepository();
    final bool hasPermission = await healthRepo.checkPermissions();

    if (!context.mounted) return;

    if (hasPermission) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.permissionPage);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0C1B3A),
              Color(0xFF1A237E),
              Color(0xFF311B92),
              Color(0xFF1A1A2E),
            ],
            stops: [0.1, 0.4, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(60 * _walkingAnimation.value, 0),
                        child: _buildWalkingIcon(),
                      ),

                      Transform.scale(
                        scale: _heartbeatAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildHeartRateIcon(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          'HealthTrack',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your Health Companion',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWalkingIcon() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Icon(Icons.directions_walk, color: Color(0xFF4CAF50), size: 40),
    );
  }

  Widget _buildHeartRateIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xFFF44336).withValues(alpha: 0.8),
          width: 2,
        ),
      ),
      child: Icon(Icons.favorite, color: Color(0xFFF44336), size: 40),
    );
  }
}

class _HeartbeatCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.2) {
      return Curves.easeIn.transform(t * 5);
    } else if (t < 0.4) {
      return 1.0 + Curves.easeOut.transform((t - 0.2) * 5) * 0.2;
    } else if (t < 0.6) {
      return 1.2 - Curves.easeIn.transform((t - 0.4) * 5) * 0.2;
    } else if (t < 0.8) {
      return 1.0 + Curves.easeOut.transform((t - 0.6) * 5) * 0.1;
    } else {
      return 1.1 - Curves.easeIn.transform((t - 0.8) * 5) * 0.1;
    }
  }
}
