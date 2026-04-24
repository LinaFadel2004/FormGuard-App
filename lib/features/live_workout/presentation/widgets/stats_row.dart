import 'package:flutter/material.dart';

import '../../../../core/constants/app_color.dart';

class StatsRow extends StatelessWidget {
  final int repsCount;
  final String formattedTime;

  const StatsRow({super.key, required this.repsCount, required this.formattedTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatBox(context, "Reps:", "$repsCount/12"),
        _buildStatBox(context, "Timer:", formattedTime),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.surfaceColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}