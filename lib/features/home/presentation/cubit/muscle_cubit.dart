import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/category_service.dart';
import 'muscle_state.dart';

class MuscleCubit extends Cubit<MuscleState> {
  final CategoryService apiService;

  MuscleCubit({required this.apiService}) : super(MuscleInitial());

  Future<void> fetchMuscleGroups() async {
    if (state is MuscleLoaded) return;

    emit(MuscleLoading());
    try {
      final response = await apiService.fetchBodyParts();
      emit(MuscleLoaded(muscleGroups: response));
    } catch (e) {
      emit(MuscleError(message: 'Failed to fetch muscle groups: $e'));
    }
  }
}
