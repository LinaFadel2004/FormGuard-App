import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_color.dart';
import '../cubit/muscle_cubit.dart';
import '../cubit/muscle_state.dart';
import '../cubit/workout_cubit.dart';
import '../screens/explore_screen.dart';

class MuscleGrid extends StatelessWidget {
  const MuscleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MuscleCubit, MuscleState>(
      builder: (context, state) {
        if (state is MuscleLoading || state is MuscleInitial) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(80.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        if (state is MuscleError) {
          return SliverToBoxAdapter(child: Center(child: Text(state.message)));
        }
        if (state is MuscleLoaded) {
          final muscleGroups = state.muscleGroups;
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = muscleGroups[index];
                return GestureDetector(
                  onTap: () {
                    context.read<WorkoutCubit>().fetchWorkoutsByBodyPart(
                      category.apiName,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExploreScreen(category: category),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(category.imageUrl, fit: BoxFit.cover),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              muscleGroups[index].name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.exerciseCount,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: muscleGroups.length),
            ),
          );
        }
        return const SliverToBoxAdapter();
      },
    );
  }
}
