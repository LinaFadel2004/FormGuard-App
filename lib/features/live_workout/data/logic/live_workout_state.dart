import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class LiveWorkoutState {}

class LiveWorkoutInitial extends LiveWorkoutState {}

class LiveWorkoutRunning extends LiveWorkoutState {
  final String aiFeedback;
  final int repsCount;
  final int remainingSeconds;
  final List<dynamic> arrowsData;
  final List<Pose> poses;
  final Size? imageSize;
  final CameraController? cameraController;

  LiveWorkoutRunning({
    required this.aiFeedback,
    required this.repsCount,
    required this.remainingSeconds,
    required this.arrowsData,
    required this.poses,
    this.imageSize,
    this.cameraController,
  });
}

class LiveWorkoutFinished extends LiveWorkoutState {
  final int totalReps;
  final int activeSeconds;
  final int formScore;
  final Map<String, int> errorFrequencies; // عشان نعرض أكتر أخطاء اتكررت

  LiveWorkoutFinished({
    required this.totalReps,
    required this.activeSeconds,
    required this.formScore,
    required this.errorFrequencies,
  });
}