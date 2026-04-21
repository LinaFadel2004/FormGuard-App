class CategoryModel {
  final String name;
  final String apiName;
  final String exerciseCount;
  final String imageUrl;

  CategoryModel({
    required this.name,
    required this.apiName,
    required this.exerciseCount,
    required this.imageUrl,
  });
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['displayName'] ?? 'Unknown Muscle',
      exerciseCount: json['exerciseCount'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      apiName: json['apiName'] ?? '',

    );
  }
}
