import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/data/models/workout_model.dart';
import '../../../workout_summary/presentation/screens/workout_summary_screen.dart';
import '../../data/logic/live_workout_cubit.dart';
import '../../data/logic/live_workout_state.dart';
import '../../data/services/camera_service.dart';
import '../../data/services/websocket_service.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/pose_painter.dart';
import '../widgets/stats_row.dart';
import '../widgets/workout_dialogs.dart';

class LiveWorkoutScreen extends StatelessWidget {
  final WorkoutModel workout;

  const LiveWorkoutScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // هنا بنحقن (Inject) الـ Services جوه الـ Cubit
      create: (context) =>
          LiveWorkoutCubit(CameraPoseService(), WebSocketService()),
      child: _LiveWorkoutView(workout: workout),
    );
  }
}

class _LiveWorkoutView extends StatefulWidget {
  final WorkoutModel workout;

  const _LiveWorkoutView({required this.workout});

  @override
  State<_LiveWorkoutView> createState() => _LiveWorkoutViewState();
}

class _LiveWorkoutViewState extends State<_LiveWorkoutView> {
  @override
  void initState() {
    super.initState();
    _checkSavedIpAndStart();
  }

  Future<void> _checkSavedIpAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('server_ip');

    if (savedIp != null && savedIp.isNotEmpty) {
      if (mounted) {
        context.read<LiveWorkoutCubit>().startWorkout(savedIp, widget.workout);
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WorkoutDialogs.showIpDialog(context, (ip) async {
          await prefs.setString('server_ip', ip);

          if (mounted) {
            context.read<LiveWorkoutCubit>().startWorkout(ip, widget.workout);
          }
        });
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<LiveWorkoutCubit, LiveWorkoutState>(
        listener: (context, state) {
          if (state is LiveWorkoutFinished) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutSummaryScreen(
                  workoutName: widget.workout.name,
                  correctReps: state.totalReps,
                  activeSeconds: state.activeSeconds,
                  formScore: state.formScore,
                  errorFrequencies: state.errorFrequencies,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LiveWorkoutRunning) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Camera
                if (state.cameraController != null &&
                    state.cameraController!.value.isInitialized)
                  CameraPreview(state.cameraController!)
                else
                  const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  ),

                // 2. Pose Painter
                if (state.poses.isNotEmpty && state.imageSize != null)
                  CustomPaint(
                    painter: PosePainter(
                      state.poses,
                      state.imageSize!,
                      state.arrowsData,
                    ),
                    size: Size.infinite,
                  ),

                // 3. Close Button
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      context.read<LiveWorkoutCubit>().finishWorkout();
                    } ,
                  ),
                ),
                // Reset IP Button
                Positioned(
                  top: 40,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.wifi_find, color: Colors.grey, size: 30),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('server_ip');
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('IP Reset! Open the workout again to enter the new IP.')),
                        );
                      }
                    },
                  ),
                ),
                // 4. AI Feedback Banner
                Positioned(
                  top: 50,
                  left: 50,
                  right: 50,
                  child: FeedbackBanner(aiFeedback: state.aiFeedback),
                ),

                // 5. العداد والتايمر (Stats Row)
                Positioned(
                  top: 130,
                  left: 20,
                  right: 20,
                  child: StatsRow(
                    repsCount: state.repsCount,
                    formattedTime: _formatTime(state.remainingSeconds),
                  ),
                ),

                // 6. Video Guide
                Positioned(
                  bottom: 50,
                  right: 20,
                  child: GestureDetector(
                    onTap: () =>
                        WorkoutDialogs.showFormGuide(context, widget.workout),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.videocam, color: Colors.black87, size: 28),
                          SizedBox(height: 4),
                          Text(
                            "Form\nVideo Guide",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        },
      ),
    );
  }
}
