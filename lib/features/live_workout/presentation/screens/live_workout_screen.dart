import 'dart:async';
import 'dart:convert'; // عشان نحول الداتا لـ JSON
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // باكيدج الويب سوكت
import '../../../home/data/models/workout_model.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;

  const LiveWorkoutScreen({super.key, required this.workout});

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  CameraController? controller;
  bool isCameraReady = false;
  bool isProcessing = false;

  List<Pose> _currentPoses = [];
  Size? _imageSize;

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(),
  );
  CameraDescription? _frontCamera;

  // 1. تعريف الـ WebSocket والـ Feedback
  WebSocketChannel? _channel;
  String _aiFeedback = "Detecting position";

  // --- متغيرات التايمر التنازلي ---
  Timer? _workoutTimer;
  int _remainingSeconds = 0;

  // دالة بتستخرج الرقم من كلمة "10 mins" وتحوله لثواني
  void _setupTimer() {
    // بناخد أول جزء من النص (الرقم)
    String durationStr = widget.workout.duration.split(' ')[0];
    int minutes =
        int.tryParse(durationStr) ?? 5; // لو حصلت مشكلة بنخليها 5 دقايق احتياطي
    _remainingSeconds = minutes * 60; // تحويل الدقايق لثواني
  }

  // دالة بتبدأ العد التنازلي
  void _startTimer() {
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            // لما الوقت يخلص نوقف التايمر
            _workoutTimer?.cancel();
            // ممكن هنا بعدين نطلع رسالة "عاش يا بطل، التمرين خلص!"
          }
        });
      }
    });
  }

  // دالة التنسيق زي ما هي مفيهاش تغيير
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _setupTimer();
    initializeCamera();
    _connectToWebSocket();
    _startTimer(); // تشغيل التايمر أول ما الشاشة تفتح
  }

  // 2. دالة الاتصال بالسيرفر
  void _connectToWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.100.8:81'));

      // الاستماع للردود اللي جاية من بايثون
      // الاستماع للردود اللي جاية من بايثون
      _channel!.stream.listen(
            (message) {
          if (mounted) {
            try {
              // 1. بنفك الطرد (الـ JSON) ونحوله لـ Map نقدر نقراه
              final Map<String, dynamic> response = jsonDecode(message.toString());

              setState(() {
                // 2. بناخد الجملة النظيفة اللي جوه مفتاح "message" بس
                _aiFeedback = response['message'] ?? "Detecting position";
              });
            } catch (e) {
              // لو بايثون بعت حاجة مش JSON بالغلط، التطبيق ميضربش إيرور
              log('Error decoding message: $e');
            }
          }
        },
        onError: (error) => log('WebSocket Error: $error'),
        onDone: () => log('WebSocket Connection Closed'),
      );
    } catch (e) {
      log('WebSocket Setup Error: $e');
    }
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        _frontCamera!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller!.initialize();
      if (!mounted) return;

      setState(() {
        isCameraReady = true;
      });

      controller!.startImageStream((CameraImage image) {
        if (isProcessing) return;
        isProcessing = true;
        _processCameraImage(image);
      });
    } catch (e) {
      log('Error initializing camera: $e');
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    try {
      if (_frontCamera == null) return;

      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final imageRotation =
          InputImageRotationValue.fromRawValue(
            _frontCamera!.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;
      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21;

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
      final List<Pose> poses = await _poseDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _currentPoses = poses;
          _imageSize = Size(image.width.toDouble(), image.height.toDouble());
        });
      }

      // 3. تجميع النقط وإرسالها لبايثون
      if (poses.isNotEmpty && _channel != null) {
        final pose = poses.first;

        // --- 1. تجميع الـ 33 نقطة في Array زي ما بايثون متوقع ---
        List<Map<String, double>> pointsList = [];
        for (int i = 0; i < 33; i++) {
          final type = PoseLandmarkType.values[i];
          final landmark = pose.landmarks[type];

          if (landmark != null) {
            pointsList.add({"x": landmark.x, "y": landmark.y, "z": landmark.z});
          } else {
            pointsList.add({
              "x": 0.0,
              "y": 0.0,
              "z": 0.0,
            }); // لو نقطة مش واضحة بنبعت أصفار
          }
        }

        // --- 2. تحويل اسم التمرين للاسم اللي بايثون كاتبه (Enum) ---
        String apiWorkoutName = "bicepCurls"; // القيمة الافتراضية
        final String uiName = widget.workout.name.toLowerCase();

        if (uiName.contains("push"))
          apiWorkoutName = "pushUps";
        else if (uiName.contains("bicep"))
          apiWorkoutName = "bicepCurls";
        else if (uiName.contains("lateral"))
          apiWorkoutName = "lateralRaises";
        else if (uiName.contains("overhead"))
          apiWorkoutName = "overheadPress";
        else if (uiName.contains("jack"))
          apiWorkoutName = "jumpingJacks";

        // --- 3. تجهيز الـ JSON وبعته ---
        final payload = {"workout": apiWorkoutName, "points": pointsList};

        _channel!.sink.add(jsonEncode(payload));
      }
    } catch (e) {
      log('Error processing image: $e');
    } finally {
      isProcessing = false;
    }
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    controller?.stopImageStream();
    controller?.dispose();
    _poseDetector.close();
    _channel?.sink.close(); // نقفل الاتصال لما نخرج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الكاميرا
          if (isCameraReady && controller != null)
            CameraPreview(controller!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          // --- الطبقة الشفافة اللي هترسم النقط ---
          if (_currentPoses.isNotEmpty && _imageSize != null)
            CustomPaint(
              painter: PosePainter(_currentPoses, _imageSize!),
              size: Size.infinite,
            ),
          // ----------------------------------------
          // زرار الرجوع واسم التمرين
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // --- عداد الوقت (Timer) ---
          // --- عداد الوقت التنازلي (Countdown Timer) ---
          Positioned(
            top: 50,
            left: 0,
            right: 20,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    // لو فاضل أقل من 60 ثانية نخلي الإطار أحمر
                    color: _remainingSeconds <= 60
                        ? Colors.redAccent.withOpacity(0.8)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      // لو فاضل أقل من 60 ثانية نخلي الأيقونة حمرا
                      color: _remainingSeconds <= 60
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_remainingSeconds),
                      // هنا حطينا الثواني المتبقية
                      style: TextStyle(
                        // لو فاضل أقل من 60 ثانية نخلي النص أحمر
                        color: _remainingSeconds <= 60
                            ? Colors.redAccent
                            : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 4. مربع عرض الـ Feedback بتاع الـ AI
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  // لو الفورم صح نخليه أخضر، لو غلط نخليه أحمر أو برتقالي
                  color: _aiFeedback.toLowerCase().contains('good')
                      ? Colors.green
                      : Colors.orange,
                  width: 2,
                ),
              ),
              child: Text(
                _aiFeedback,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size absoluteImageSize;

  PosePainter(this.poses, this.absoluteImageSize);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. فرشة رسم النقط
    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    // 2. فرشة رسم الخطوط
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.greenAccent.withOpacity(0.8);

    // قائمة بنقط الوجه اللي عايزين نخفيها
    final faceLandmarks = {
      PoseLandmarkType.nose,
      PoseLandmarkType.leftEyeInner,
      PoseLandmarkType.leftEye,
      PoseLandmarkType.leftEyeOuter,
      PoseLandmarkType.rightEyeInner,
      PoseLandmarkType.rightEye,
      PoseLandmarkType.rightEyeOuter,
      PoseLandmarkType.leftEar,
      PoseLandmarkType.rightEar,
      PoseLandmarkType.leftMouth,
      PoseLandmarkType.rightMouth,
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

      // --- رسم الخطوط (الهيكل العظمي للجسم فقط) ---
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

      // --- رسم النقط مع فلترة الوجه ---
      pose.landmarks.forEach((type, landmark) {
        // الشرط ده بيقول: لو النقطة مش في الوجه، ارسمها
        if (!faceLandmarks.contains(type)) {
          final double x = size.width - (landmark.x * scaleX);
          final double y = landmark.y * scaleY;
          canvas.drawCircle(Offset(x, y), 4, pointPaint);
        }
      });
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}
