class WorkoutModel {
  final String name;
  final String duration;
  final String level;
  final String imageUrl;
  final String bodyPart;
  final String targetMuscle;
  final String category;

  WorkoutModel({
    required this.name,
    required this.duration,
    required this.level,
    required this.imageUrl,
    required this.bodyPart,
    required this.targetMuscle,
    required this.category,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      name: json['name'] ?? 'Unknown Workout',
      duration: json['duration'] ?? '',
      level: json['level'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      targetMuscle: json['targetMuscle'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

// class WorkoutModel {
//   final String id;
//   final String name;
//   final String difficulty;
//   final String bodyPart;
//
//   final int duration;
//
//   WorkoutModel({
//     required this.bodyPart,
//     required this.name,
//     required this.difficulty,
//     required this.id,
//
//     this.duration = 15,
//   });
//
//   factory WorkoutModel.fromJson(Map<String, dynamic> json) {
//     return WorkoutModel(
//       bodyPart: json['bodyPart'] ?? 'Body Part',
//       name: json['name'] ?? 'Name',
//       difficulty: json['difficulty'] ?? 'Difficulty',
//       id: json['id'] ?? 'ID',
//     );
//   }
//   String getImageUrl (String apiKey){
//     return 'https://exercisedb.p.rapidapi.com/image?exerciseId=$id&resolution=180&rapidapi-key=$apiKey';
//   }
// }
