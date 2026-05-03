import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math' as math;

import '../../../../core/constants/app_color.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;
  final List<dynamic> arrowsData;

  PosePainter(this.poses, this.absoluteImageSize, this.arrowsData);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()..style = PaintingStyle.fill..strokeWidth = 3.0..color = AppColor.primaryColor;
    final linePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 4.0..color = AppColor.primaryColor.withOpacity(0.8);
    // كبّرت عرض السهم شوية عشان يكون أوضح لليوزر
    final arrowPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 8.0..color = AppColor.errorColor..strokeCap = StrokeCap.round;

    final faceLandmarks = {
      PoseLandmarkType.nose, PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter,
      PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter, PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar, PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth,
    };

    for (final pose in poses) {
      final double scaleX = size.width / absoluteImageSize.height;
      final double scaleY = size.height / absoluteImageSize.width;

      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final PoseLandmark? joint1 = pose.landmarks[type1];
        final PoseLandmark? joint2 = pose.landmarks[type2];
        if (joint1 != null && joint2 != null) {
          final x1 = size.width - (joint1.x * scaleX);
          final y1 = joint1.y * scaleY;
          final x2 = size.width - (joint2.x * scaleX);
          final y2 = joint2.y * scaleY;
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }

      // Skeleton lines
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

      // Points
      pose.landmarks.forEach((type, landmark) {
        if (!faceLandmarks.contains(type)) {
          final double x = size.width - (landmark.x * scaleX);
          final double y = landmark.y * scaleY;
          canvas.drawCircle(Offset(x, y), 4, pointPaint);
        }
      });

      // Arrows
      for (var arrow in arrowsData) {
        try {
          double normX = arrow['point'][0];
          double normY = arrow['point'][1];

          double startX = size.width - (normX * size.width);
          double startY = normY * size.height;

          double dirX = arrow['direction'][0];
          double dirY = arrow['direction'][1];
          double len = 70.0;

          double endX = startX - (dirX * len);
          double endY = startY + (dirY * len);

          canvas.drawLine(Offset(startX, startY), Offset(endX, endY), arrowPaint);

          double angle = math.atan2(endY - startY, endX - startX);
          canvas.drawLine(Offset(endX, endY), Offset(endX - 20 * math.cos(angle - math.pi / 6), endY - 20 * math.sin(angle - math.pi / 6)), arrowPaint);
          canvas.drawLine(Offset(endX, endY), Offset(endX - 20 * math.cos(angle + math.pi / 6), endY - 20 * math.sin(angle + math.pi / 6)), arrowPaint);
        } catch (_) {}
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return true;
  }
}