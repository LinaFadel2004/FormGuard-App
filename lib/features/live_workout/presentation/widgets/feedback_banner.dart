import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';

class FeedbackBanner extends StatelessWidget {
  final String aiFeedback;

  const FeedbackBanner({super.key, required this.aiFeedback});

  @override
  Widget build(BuildContext context) {
    if (aiFeedback == "Detecting position") return const SizedBox.shrink();

    final isGood = aiFeedback.toLowerCase().contains('good');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: isGood
            ? AppColor.primaryColor.withOpacity(0.85)
            : AppColor.errorColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isGood ? "PERFECT!" : "ERROR!",
            style: const TextStyle(color: AppColor.surfaceColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            aiFeedback,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColor.surfaceColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}