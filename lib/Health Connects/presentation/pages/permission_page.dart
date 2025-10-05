// lib/Health Connects/presentation/view/permissions_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:health_connect/Health%20Connects/presentation/routes/appRoutes.dart';

import '../../data/repository/health_repository.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  Future<void> _requestPermissions(BuildContext context) async {
    final healthRepo = HealthRepository();
    final bool granted = await healthRepo.requestPermissions();

    if (granted && context.mounted) {
      context.go(AppRoutes.dashboard);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions were not granted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Using the same gradient as your dashboard
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0C1B3A),
              Color(0xFF1A237E),
              Color(0xFF311B92),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 80),
                const SizedBox(height: 24),
                const Text(
                  'Health Data Access',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'To display your steps and heart rate on the dashboard, this app needs permission to read data from Health Connect.',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _requestPermissions(context),
                  child: const Text('Grant Access'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
