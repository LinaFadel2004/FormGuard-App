import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/workout_model.dart';

class WorkoutService {
  Future<List<WorkoutModel>> fetchWorkouts() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/workouts.json',
      );

      final List<dynamic> data = json.decode(response);

      return data.map((json) => WorkoutModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading local API: $e');
    }
  }

  Future<List<WorkoutModel>> fetchByBodyPart(String bodyPart) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/workouts.json',
      );
      final List<dynamic> data = json.decode(response);
      final List<WorkoutModel> workouts = data
          .map((json) => WorkoutModel.fromJson(json))
          .toList();
      return workouts.where((workout) => workout.bodyPart == bodyPart).toList();

    } catch (e) {
      throw Exception('Error loading local API: $e');
    }
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/workout_model.dart';
//
// class WorkoutApiService {
//   final String allExercisesUrl = 'https://exercisedb.p.rapidapi.com/exercises';
//   final String bodyPartsUrl =
//       'https://exercisedb.p.rapidapi.com/exercises/bodyPartList';
//   final String apiKey = '4d49d58859msha4b1c6084cb3bbfp1a441djsn666b799e0b28';
//
//   Future<List<WorkoutModel>> fetchWorkouts() async {
//     try {
//       final response = await http.get(
//         Uri.parse(allExercisesUrl),
//         headers: {
//           'X-RapidAPI-Key': apiKey,
//           'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         List<WorkoutModel> workouts = data
//             .map((data) => WorkoutModel.fromJson(data))
//             .toList();
//         return workouts;
//       } else {
//         throw Exception(
//           'Failed to load workouts: Error ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Error fetching data: $e');
//     }
//   }
//
//   Future<List<String>> fetchBodyParts() async {
//     try {
//       final response = await http.get(
//         Uri.parse(bodyPartsUrl),
//         headers: {
//           'X-RapidAPI-Key': apiKey,
//           'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
//         },
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         List<String> bodyParts = List<String>.from(data);
//         return bodyParts;
//       } else {
//         throw Exception(
//           'Failed to load body parts: Error ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Error fetching data: $e');
//     }
//   }
// }
