import 'package:formguard/features/home/data/models/category_model.dart';

abstract class MuscleState {}

class MuscleInitial extends MuscleState {}

class MuscleLoading extends MuscleState {}

class MuscleLoaded extends MuscleState {
  final List<CategoryModel> muscleGroups;
  MuscleLoaded({required this.muscleGroups});
}

class MuscleError extends MuscleState {
  final String message;
  MuscleError({required this.message});
}

