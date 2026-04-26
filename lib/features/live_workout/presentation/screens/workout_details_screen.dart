import 'package:flutter/material.dart';
import 'package:formguard/features/live_workout/presentation/widgets/details_card.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_color.dart';
import '../../../home/data/models/workout_model.dart';
import 'live_workout_screen.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Lottie.asset(
                  workout.gifUrl,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.contain,
                ),
                //decoration gradient
                Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                //back button
                SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                //workout name
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Text(
                    workout.name,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DetailsCard(
                        icon: Icons.timer_outlined,
                        value: workout.duration,
                        title: 'Duration',
                      ),
                      DetailsCard(
                        icon: Icons.fitness_center,
                        value: workout.level,
                        title: 'Level',
                      ),
                      DetailsCard(
                        icon: Icons.my_location_rounded,
                        value: workout.targetMuscle,
                        title: 'Muscle',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'About this Workout',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'This ${workout.category} exercise focuses on your ${workout.targetMuscle}. It is perfect for ${workout.level.toLowerCase()}s looking to build strength and perfect their form.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveWorkoutScreen(workout: workout),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'START EXERCISE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
