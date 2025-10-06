import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/info_card_modal.dart';
import '../widget/chart_widget.dart';
import '../widget/info_card.dart';
import '../widget/performance_hud.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardController>().init();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Health Connect Dashboard'),
        backgroundColor: Color(0xFF0C1B3A),
        elevation: 0,
        toolbarHeight: kToolbarHeight + 20,
        actions: [
          if (kDebugMode)
            IconButton(
              key: const ValueKey('simsource_toggle_button'),
              icon: Icon(
                controller.isSimulating ? Icons.stop_circle : Icons.play_circle,
                color: controller.isSimulating
                    ? Colors.redAccent
                    : Colors.greenAccent,
              ),
              tooltip: 'Toggle SimSource',
              onPressed: () {
                context.read<DashboardController>().toggleSimulation();
              },
            ),
        ],

        foregroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0C1B3A),
              Color(0xFF1A237E),
              Color(0xFF311B92),
              Color(0xFF1A1A2E),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: DashboardWidget(),
      ),
    );
  }
}

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ///info card
              Center(
                child: SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        child: InfoCard(
                          modal: InfoCardModal(
                            title: "Today's Steps",
                            value: controller.totalSteps.toString(),
                            icon: Icons.directions_walk,
                            subValue: null,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF45C7C1)],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InfoCard(
                          modal: InfoCardModal(
                            title: "Current Heart Rate",
                            value: "${controller.currentHeartRate} bpm",
                            subValue: controller.heartRateTimestampAge,
                            icon: Icons.favorite,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF44336), Color(0xFFFF7597)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Steps chart container
              Expanded(
                flex: 2,
                child: ChartContainer(
                  title: controller.chartData[0].title,
                  gradient: controller.chartData[0].gradient,
                  data: controller.stepDataPoints,
                  startYAxisAtZero: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 3,
                child: ChartContainer(
                  title: controller.chartData[1].title,
                  gradient: controller.chartData[1].gradient,
                  data: controller.heartRateDataPoints,
                  startYAxisAtZero: false,
                ),
              ),
            ],
          ),
        ),

        if (kDebugMode)
          Positioned(
            bottom: 16,
            right: 16,
            child: PerformanceHud(
              buildTimeMs: controller.averageBuildTimeMs,
              fps: controller.fps,
            ),
          ),
      ],
    );
  }
}
