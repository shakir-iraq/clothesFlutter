import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yahya_new_app/model/size.dart';

class ApiSiize {
  static const String baseUrl = 'http://192.168.18.3:7045/api/GetAll';

  Future<List<Siize>> getAllSizeFromApi() async {
    final response = await http.get(Uri.parse('$baseUrl/siizes'));

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((json) => Siize.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sizes');
    }
  }

  Future<void> postSizeToApi(Siize size) async {
    final response = await http.post(
      Uri.parse('$baseUrl/siizes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': size.name}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add size');
    }
  }

  Future<void> deleteSiize(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/Siizes/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('فشل في حذف اللون');
    }
  }
}
