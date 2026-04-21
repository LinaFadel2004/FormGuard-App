import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formguard/features/home/presentation/cubit/workout_state.dart';

import '../../data/services/workout_service.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutService apiService;
  WorkoutCubit({required this.apiService}) : super(WorkoutInitial());

  Future<void> fetchRecommendedWorkouts() async{
    if (state is WorkoutLoaded) return;
    emit(WorkoutLoading());
    try {
      final response = await apiService.fetchWorkouts();
      emit(WorkoutLoaded(workouts: response));
    }catch(e){
      emit(WorkoutError(message: 'Failed to fetch recommended workouts: $e'));
    }
  }
  Future<void> fetchWorkoutsByBodyPart(String bodyPart) async {
    if (state is WorkoutLoaded) return;
    emit(WorkoutLoading());
    try {
      final response = await apiService.fetchByBodyPart(bodyPart);
      emit(WorkoutLoaded(workouts: response));
    } catch (e) {
      emit(WorkoutError(message: 'Failed to fetch workouts: $e'));
    }
  }
}