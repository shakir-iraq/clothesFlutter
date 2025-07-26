import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yahya_new_app/model/Coolor.dart';

class ApiCoolor {
  static const String baseUrl = 'http://192.168.18.3:7045/api/GetAll';

  Future<List<Coolor>> getAllCoolorFromApi() async {
    final response = await http.get(Uri.parse('$baseUrl/coolors'));

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((json) => Coolor.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load colors');
    }
  }

  Future<void> postcoolorToApi(Coolor coolor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/coolors'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': coolor.name}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add coolor');
    }
  }

  Future<void> deleteColor(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/Coolors/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('فشل في حذف اللون');
    }
  }
}
