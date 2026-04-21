import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formguard/features/home/presentation/widgets/workout_card.dart';
import '../cubit/workout_cubit.dart';
import '../cubit/workout_state.dart';

class RecommendedWorkouts extends StatelessWidget {
  const RecommendedWorkouts({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        if (state is WorkoutLoading || state is WorkoutInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is WorkoutError) {
          return Center(child: Text(state.message));
        }
        if (state is WorkoutLoaded) {
          final workouts = state.workouts;
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return WorkoutCard(
                  imageUrl: workout.imageUrl,
                  name: workout.name,
                  duration: workout.duration,
                  level: workout.level,
                  workout: workout,
                );
              },
            ),
          );
        }

        return SizedBox();
      },
    );
  }
}
