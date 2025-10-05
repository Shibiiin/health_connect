import 'package:flutter/material.dart';
import 'package:health_connect/Health%20Connects/presentation/manager/dashboard_controller.dart';
import 'package:provider/provider.dart';

import '../widget/chart_widget.dart';
import '../widget/info_card.dart';
import '../widget/performance_hud.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

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
          IconButton(
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
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.infoCards.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, _) => const SizedBox(width: 25),
                    itemBuilder: (context, index) {
                      final card = controller.infoCards[index];
                      return InfoCard(modal: card);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Steps chart container
              Expanded(
                child: ListView.separated(
                  itemCount: controller.chartData.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final chart = controller.chartData[index];
                    return SizedBox(height: 200, child: ChartContainer(chart));
                  },
                ),
              ),
            ],
          ),
        ),

        const Positioned(
          bottom: 16,
          right: 16,
          child: PerformanceHud(buildTimeMs: '4.2ms', fps: '60'),
        ),
      ],
    );
  }
}
