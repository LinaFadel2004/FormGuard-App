import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraPoseService {
  CameraController? controller;
  bool _isProcessing = false;

  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions());
  CameraDescription? _frontCamera;

  // الدالة دي بتاخد Callback (دالة تانية) عشان لما الكاميرا تلاقي "هيكل جسم"، تبعتهولها فوراً
  Future<void> initializeCamera(Function(List<Pose> poses, Size imageSize) onPoseDetected) async {
    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        _frontCamera!,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();

      // بنبدأ ناخد الصور من الكاميرا فريم بفريم
      controller!.startImageStream((CameraImage image) {
        if (_isProcessing) return;
        _isProcessing = true;
        _processCameraImage(image, onPoseDetected);
      });

    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  // الدالة دي مسؤولة عن تحويل صورة الكاميرا لبيانات يفهمها الذكاء الاصطناعي
  Future<void> _processCameraImage(CameraImage image, Function(List<Pose>, Size) onPoseDetected) async {
    try {
      if (_frontCamera == null) return;

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final imageRotation = InputImageRotationValue.fromRawValue(_frontCamera!.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      // هنا الـ ML Kit بيطلع النقط
      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      // بنبعت النقط وحجم الشاشة للـ Callback عشان الـ Cubit أو الـ UI يستخدمهم
      onPoseDetected(poses, imageSize);

    } catch (e) {
      log('Error processing image: $e');
    } finally {
      // بنفتح الباب للفريم اللي بعده
      _isProcessing = false;
    }
  }

  void dispose() {
    controller?.stopImageStream();
    controller?.dispose();
    _poseDetector.close();
  }
}