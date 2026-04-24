import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_color.dart';
import '../../../home/data/models/workout_model.dart';

class WorkoutDialogs {
  // 1. IP Connection Dialog
  static void showIpDialog(BuildContext context, Function(String) onConnect) {
    TextEditingController ipController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColor.secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Server Connection", style: TextStyle(color: AppColor.surfaceColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter the AI Server IP Address:", style: TextStyle(color: AppColor.greyColor, fontSize: 14)),
              const SizedBox(height: 10),
              TextField(
                controller: ipController,
                style: const TextStyle(color: AppColor.surfaceColor),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "e.g., 192.168.1.5",
                  hintStyle: const TextStyle(color: AppColor.textSecondaryColor),
                  filled: true,
                  fillColor: Colors.black45,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColor.primaryColor)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: AppColor.errorColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              onPressed: () {
                if (ipController.text.isNotEmpty) {
                  Navigator.pop(context);
                  onConnect(ipController.text.trim());
                }
              },
              child: const Text("Connect", style: TextStyle(color: AppColor.surfaceColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 2. Form Guide Bottom Sheet
  static void showFormGuide(BuildContext context, WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColor.surfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: AppColor.greyColor, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${workout.name} Setup", style: Theme.of(context).textTheme.titleLarge),
                  IconButton(icon: const Icon(Icons.cancel, color: AppColor.textSecondaryColor, size: 28), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: workout.gifUrl.endsWith('.json')
                    ? Lottie.asset(workout.gifUrl, height: 200, width: double.infinity, fit: BoxFit.contain)
                    : Image.asset(workout.gifUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),

              const SizedBox(height: 20),
              Text(
                  "Ensure back is straight, and hands are aligned forward. Keep your core tight.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 15, height: 1.5)
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Got it, Continue Workout!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColor.surfaceColor)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}