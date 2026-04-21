import 'package:flutter/material.dart';

import '../../../../core/constants/app_color.dart';

class DetailsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const DetailsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Icon(icon, color: AppColor.primaryColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
