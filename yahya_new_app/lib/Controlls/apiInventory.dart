import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yahya_new_app/model/inventory.dart';

class ApiInventory {
  static const String baseUrl =
      'http://192.168.18.3:7045/api/GetAll/inventories';

  static Future<List<Inventory>> fetchInventories() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List list = json.decode(response.body);
      return list.map((e) => Inventory.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load inventories');
    }
  }

  static Future<void> addInventory(
      int productId, int coolorId, int siizeId, int quantity) async {
    final Map<String, dynamic> data = {
      "productId": productId,
      "coolorId": coolorId,
      "siizeId": siizeId,
      "quantity": quantity,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add inventory');
    }
  }

  static Future<bool> updateInventory({
    required int id,
    required int productId,
    required int coolorId,
    required int siizeId,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "id": id,
        "productId": productId,
        "coolorId": coolorId,
        "siizeId": siizeId,
        "quantity": quantity,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> deleteInventory(int id) async {
    final url = 'http://192.168.18.3:7045/api/GetAll/inventories/$id';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("فشل في حذف المخزون");
    }
  }
}
