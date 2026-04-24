class AiFeedbackModel {
  final String message;
  final int reps;
  final List<dynamic> arrows;

  AiFeedbackModel({
    required this.message,
    required this.reps,
    required this.arrows,
  });

  // الدالة دي بتاخد الـ JSON اللي جاي من بايثون وبتحوله لأوبجيكت
  factory AiFeedbackModel.fromJson(Map<String, dynamic> json) {
    // تنظيف الرسالة من الأرقام والأقواس زي ما عملنا قبل كده
    String rawMessage = json['message'] ?? "Detecting position";
    String cleanMessage = rawMessage.replaceAll(RegExp(r'\s*\(.*?\)'), '');

    if (cleanMessage.isNotEmpty && cleanMessage != "Good form" && cleanMessage != "Detecting position") {
      cleanMessage = cleanMessage[0].toUpperCase() + cleanMessage.substring(1);
    }

    return AiFeedbackModel(
      message: cleanMessage,
      reps: json['reps'] ?? 0,
      arrows: json['arrows'] ?? [],
    );
  }
}