import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formguard/core/theme/app_theme.dart';
import 'package:formguard/features/home/data/services/category_service.dart';
import 'package:formguard/features/home/presentation/screens/home_screen.dart';

import 'features/home/data/cubit/muscle_cubit.dart';
import 'features/home/data/cubit/workout_cubit.dart';
import 'features/home/data/services/workout_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: getTheme(),
      debugShowCheckedModeBanner: false,
      home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => MuscleCubit(apiService: CategoryService())..fetchMuscleGroups()),
            BlocProvider(create: (context) => WorkoutCubit(apiService: WorkoutService())..fetchRecommendedWorkouts()),
          ],
          child: HomeScreen()
      ),
    );
  }
}
