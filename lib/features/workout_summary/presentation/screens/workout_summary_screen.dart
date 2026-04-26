import 'package:flutter/material.dart';
import '../../../../core/constants/app_color.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final String workoutName;
  final int correctReps;
  final int activeSeconds;
  final double formScore;
  final Map<String, int> errorFrequencies;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutName,
    required this.correctReps,
    required this.activeSeconds,
    required this.formScore,
    required this.errorFrequencies,
  });

  @override
  Widget build(BuildContext context) {
    // حساب الكالوريز تقريبياً (مثلاً 6 كالوري في الدقيقة)
    final int calories = (activeSeconds / 60 * 6).toInt();
    final String timeStr = "${activeSeconds ~/ 60}m ${activeSeconds % 60}s";

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text("WORKOUT SUMMARY", style: TextStyle(color: AppColor.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildScoreSection(),
            const SizedBox(height: 16),
            _buildKeyFeedback(), // دي بقت دايناميك بالأخطاء الحقيقية
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatText("Total Active Time", timeStr),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                _buildStatText("Calories", "$calories kcal"),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("Done", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCircularProgress("Correct Reps:\n$workoutName", "$correctReps", AppColor.primaryColor, correctReps / 15), // بافتراض التارجت 15
          _buildCircularProgress("Form Score:\nForm", "$formScore%", formScore > 70 ? Colors.green : Colors.orange, formScore / 100),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(String title, String value, Color color, double progress) {
    return Column(
      children: [
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80, width: 80,
              child: CircularProgressIndicator(value: progress.clamp(0.0, 1.0), strokeWidth: 8, backgroundColor: Colors.grey.shade200, color: color),
            ),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyFeedback() {
    // ترتيب الأخطاء من الأكثر تكراراً للأقل
    var sortedErrors = errorFrequencies.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    // هناخد أعلى 3 أخطاء بس
    var topErrors = sortedErrors.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Key Feedback", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          topErrors.isEmpty
              ? const Center(child: Text("Perfect Form! No major errors detected. 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))
              : Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: topErrors.map((e) => _buildFeedbackCard(e.key, e.value)).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String errorText, int count) {
    // بناخد أول كلمتين بس من الخطأ عشان الكارت ميكبرش أوي
    List<String> words = errorText.split(' ');
    String shortError = words.take(2).join(' ');

    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 1)]),
      child: Column(
        children: [
          CircleAvatar(radius: 16, backgroundColor: Colors.orange.shade700, child: const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.white)),
          const SizedBox(height: 8),
          Text("$shortError\n($count times)", textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatText(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }
}