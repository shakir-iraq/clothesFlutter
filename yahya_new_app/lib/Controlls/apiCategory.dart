import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yahya_new_app/model/category.dart';

class ApiCategory {
  static const String baseUrl = 'http://192.168.18.3:7045/api/GetAll';

  Future<List<Categorys>> getAllCategoriesFromApi() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((json) => Categorys.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> postCategoryToApi(Categorys category) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': category.name}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add category');
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/categories/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('فشل في حذف اللون');
    }
  }
}
