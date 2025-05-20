import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatmap extends StatelessWidget {
  final DateTime? startData;
  final Map<DateTime, int>? dataset;
  const MyHeatmap({super.key, required this.startData, required this.dataset});

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: startData,
      endDate: DateTime.now(),
      datasets: dataset,
      colorMode: ColorMode.color,
      defaultColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.inversePrimary,
      showColorTip: false,
      showText: true,
      scrollable: true,
      size: 30,
      colorsets: {
        1: Colors.green.shade200,
        2: Colors.green.shade300,
        3: Colors.green.shade400,
        4: Colors.green.shade500,
        5: Colors.green.shade600,
      },
    );
  }
}
