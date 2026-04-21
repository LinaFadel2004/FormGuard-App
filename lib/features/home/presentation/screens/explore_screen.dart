import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formguard/features/home/data/models/workout_model.dart';
import 'package:formguard/features/home/presentation/cubit/workout_cubit.dart';
import 'package:formguard/features/home/presentation/widgets/workout_card.dart';

import '../../data/models/category_model.dart';
import '../../data/services/workout_service.dart';
import '../cubit/workout_state.dart';

class ExploreScreen extends StatelessWidget {
  final CategoryModel category;

  const ExploreScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          WorkoutCubit(apiService: WorkoutService())
            ..fetchWorkoutsByBodyPart(category.apiName),
      child: Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: BlocBuilder<WorkoutCubit, WorkoutState>(
          builder: (context, state) {
            if (state is WorkoutLoading || state is WorkoutInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WorkoutError) {
              return Center(child: Text(state.message));
            }

            if (state is WorkoutLoaded) {
              return ListView.builder(
                itemCount: state.workouts.length,
                itemBuilder: (context, index) {
                  final workout = state.workouts[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: WorkoutCard(
                      imageUrl: workout.imageUrl,
                      name: workout.name,
                      duration: workout.duration,
                      level: workout.level,
                      workout: workout,
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
