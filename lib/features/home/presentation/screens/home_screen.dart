import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/category_filter.dart';
import '../widgets/header.dart';
import '../widgets/muscle_group_grid.dart';
import '../widgets/recommended_workouts.dart';
import '../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Future<void> processStaticImagesForAI() async {
  //   // قائمة أسماء المفاصل بنفس ترتيب MediaPipe / ML Kit العالمي
  //   const List<String> landmarkNames = [
  //     "nose", "left_eye_inner", "left_eye", "left_eye_outer",
  //     "right_eye_inner", "right_eye", "right_eye_outer",
  //     "left_ear", "right_ear", "mouth_left", "mouth_right",
  //     "left_shoulder", "right_shoulder", "left_elbow", "right_elbow",
  //     "left_wrist", "right_wrist", "left_pinky", "right_pinky",
  //     "left_index", "right_index", "left_thumb", "right_thumb",
  //     "left_hip", "right_hip", "left_knee", "right_knee",
  //     "left_ankle", "right_ankle", "left_heel", "right_heel",
  //     "left_foot_index", "right_foot_index"
  //   ];
  //
  //   List<String> imageNames = ['bicep.jpeg', 'lateral.jpeg'];
  //
  //   for (String imageName in imageNames) {
  //     print("\n=========================================");
  //     print("جاري معالجة الصورة: $imageName ...");
  //
  //     try {
  //       final byteData = await rootBundle.load('assets/images/$imageName');
  //       final tempDir = await getTemporaryDirectory();
  //       final file = File('${tempDir.path}/$imageName');
  //       await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //
  //       var decodedImage = await decodeImageFromList(file.readAsBytesSync());
  //       double width = decodedImage.width.toDouble();
  //       double height = decodedImage.height.toDouble();
  //
  //       final inputImage = InputImage.fromFilePath(file.path);
  //       final poseDetector = PoseDetector(options: PoseDetectorOptions());
  //       final List<Pose> poses = await poseDetector.processImage(inputImage);
  //
  //       if (poses.isNotEmpty) {
  //         final pose = poses.first;
  //         List<Map<String, dynamic>> pointsList = [];
  //
  //         print("\n\n\n--- (Normalized Coordinates) ---");
  //         for (int i = 0; i < 33; i++) {
  //           final landmark = pose.landmarks[PoseLandmarkType.values[i]];
  //           String name = landmarkNames[i]; // بجيب الاسم بناءً على الترتيب
  //
  //           double x = 0.0, y = 0.0, z = 0.0;
  //
  //           if (landmark != null) {
  //             x = landmark.x / width;
  //             y = landmark.y / height;
  //             z = landmark.z / width;
  //           }
  //
  //           // طباعة الاسم وقدامه الإحداثيات بالشكل اللي طلبتيه
  //           print("$name: [${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)}, ${z.toStringAsFixed(4)}]");
  //
  //           pointsList.add({"x": x, "y": y, "z": z});
  //         }
  //
  //         // الـ JSON الكامل عشان لو احتاجوا يرفعوه في ملف
  //         Map<String, dynamic> finalPayload = {
  //           "workout": "static_test",
  //           "width": width,
  //           "height": height,
  //           "points": pointsList
  //         };
  //
  //         print("\n--- الـ JSON الكامل للصورة ---");
  //         print(jsonEncode(finalPayload));
  //
  //       } else {
  //         print("مفيش جسم ظهر في الصورة!");
  //       }
  //       poseDetector.close();
  //     } catch (e) {
  //       print("حصل مشكلة في صورة $imageName: $e");
  //     }
  //   }
  //   print("=========================================\n");
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: Header(userName: 'Lina')),
            // SliverToBoxAdapter(child: CategoryFilter()),
            SliverToBoxAdapter(
              child: SectionTitle(title: 'Recommended Workouts'),
            ),
            SliverToBoxAdapter(child: RecommendedWorkouts()),
            SliverToBoxAdapter(child: SectionTitle(title: 'Explore by Muscle')),
            MuscleGrid(),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
            // SliverToBoxAdapter(
            //     child: ElevatedButton(
            //         onPressed: () {
            //           processStaticImagesForAI();
            //         },
            //         child: Text('Test')
            //     ),)
          ],
        ),
      ),
    );
  }
}
