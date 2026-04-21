import '../../data/models/workout_model.dart';

abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<WorkoutModel> workouts;
  WorkoutLoaded({required this.workouts});
}

class WorkoutError extends WorkoutState {
  final String message;
  WorkoutError({required this.message});
}


