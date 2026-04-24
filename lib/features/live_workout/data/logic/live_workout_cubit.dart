import 'dart:async';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../../../home/data/models/workout_model.dart';
import '../../data/models/ai_feedback_model.dart';
import '../../data/services/websocket_service.dart';
import '../services/camera_service.dart';
import 'live_workout_state.dart';


class LiveWorkoutCubit extends Cubit<LiveWorkoutState> {
  final CameraPoseService _cameraService;
  final WebSocketService _webSocketService;

  LiveWorkoutCubit(this._cameraService, this._webSocketService)
      : super(LiveWorkoutInitial());

  Timer? _timer;
  int _remainingSeconds = 0;
  int _activeSeconds = 0;

  String _aiFeedback = "Detecting position";
  int _repsCount = 0;
  List<dynamic> _arrowsData = [];
  List<Pose> _currentPoses = [];
  Size? _imageSize;

  List<String> _errorLog = [];

  // 1. بدء التمرين
  void startWorkout(String ipAddress, WorkoutModel workout) {
    // تجهيز التايمر من الـ duration بتاع الموديل
    int minutes = int.tryParse(workout.duration.split(' ')[0]) ?? 5;
    _remainingSeconds = minutes * 60;

    // الاتصال بسيرفر بايثون
    _webSocketService.connect(ipAddress, _onWebSocketMessage);

    // تشغيل الكاميرا واستقبال الـ frames
    _cameraService.initializeCamera((poses, size) {
      _currentPoses = poses;
      _imageSize = size;

      // حماية سيرفر بايثون من الكراش: مش بنبعت داتا غير لو في شخص في الكاميرا
      if (poses.isNotEmpty) {
        _webSocketService.sendPoseData(
          workoutName: _mapWorkoutName(workout.name),
          points: _formatPoints(poses),
        );
      } else {
        _aiFeedback = "Detecting position";
      }

      _emitRunningState();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _activeSeconds++;
        _emitRunningState();
      } else {
        finishWorkout();
      }
    });
  }

  // 2. استقبال الرسائل من الـ WebSocket
  void _onWebSocketMessage(AiFeedbackModel feedback) {
    _aiFeedback = feedback.message;
    _repsCount = feedback.reps;
    _arrowsData = feedback.arrows;

    // تسجيل الأخطاء (بنتجاهل الرسائل الإيجابية أو المحايدة)
    if (_aiFeedback != "Perfect!" && _aiFeedback != "Detecting position") {
      _errorLog.add(_aiFeedback);
    }

    _emitRunningState();
  }

  // 3. إنهاء التمرين وحساب النتائج (بتتنده لما التايمر يخلص أو لما اليوزر يدوس X)
  void finishWorkout() {
    _timer?.cancel();

    // تجميع أكثر الأخطاء تكراراً
    Map<String, int> errorFreq = {};
    for (var error in _errorLog) {
      errorFreq[error] = (errorFreq[error] ?? 0) + 1;
    }

    // حساب الـ Form Score
    int score = 100 - (_errorLog.length * 2); // خصم درجتين على كل خطأ كمثال
    if (score < 0) score = 0;
    if (_repsCount == 0 && _errorLog.isEmpty) score = 0; // لو ملعبش حاجة خالص

    emit(LiveWorkoutFinished(
      totalReps: _repsCount,
      activeSeconds: _activeSeconds,
      formScore: score,
      errorFrequencies: errorFreq,
    ));
  }

  // 4. تحديث حالة الشاشة
  void _emitRunningState() {
    if (isClosed) return;
    emit(
      LiveWorkoutRunning(
        aiFeedback: _aiFeedback,
        repsCount: _repsCount,
        remainingSeconds: _remainingSeconds,
        arrowsData: _arrowsData,
        poses: _currentPoses,
        imageSize: _imageSize,
        cameraController: _cameraService.controller,
      ),
    );
  }

  // 5. تجهيز النقط للصيغة اللي بايثون بيفهمها
  List<Map<String, double>> _formatPoints(List<Pose> poses) {
    List<Map<String, double>> pointsList = [];
    if (poses.isEmpty) return pointsList;

    final pose = poses.first;
    for (int i = 0; i < 33; i++) {
      final landmark = pose.landmarks[PoseLandmarkType.values[i]];
      pointsList.add(
        landmark != null
            ? {"x": landmark.x, "y": landmark.y, "z": landmark.z}
            : {"x": 0.0, "y": 0.0, "z": 0.0},
      );
    }
    return pointsList;
  }

  // 6. تحويل اسم التمرين للإسم المعتمد في الـ API
  String _mapWorkoutName(String uiName) {
    uiName = uiName.toLowerCase();
    if (uiName.contains("push")) return "pushups";
    if (uiName.contains("bicep")) return "bicepCurls";
    if (uiName.contains("lateral")) return "lateralRaises";
    if (uiName.contains("overhead")) return "overheadPress";
    if (uiName.contains("tricep")) return "overheadTricepExtension";
    return "bicepCurls";
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _cameraService.dispose();
    _webSocketService.dispose();
    return super.close();
  }
}