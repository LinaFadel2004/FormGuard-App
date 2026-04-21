import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:formguard/features/home/data/models/category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> fetchBodyParts() async {
    try{
      final String response = await rootBundle.loadString(
        'assets/data/categories.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => CategoryModel.fromJson(json)).toList();

    }catch(e){
      throw Exception('Error loading local API: $e');
      }
  }
}