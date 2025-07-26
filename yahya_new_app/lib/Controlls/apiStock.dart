import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yahya_new_app/model/stock.dart';

class ApiStock {
  final String baseUrl = 'http://192.168.18.3:7045/api';

  Future<List<Stock>> fetchStockMovements({
    int? inventoryId,
    int? movementType,
  }) async {
    String url = '$baseUrl/GetAll/stockmovements';
    final params = <String, String>{};
    if (inventoryId != null) params['inventoryId'] = inventoryId.toString();
    if (movementType != null) params['movementType'] = movementType.toString();

    if (params.isNotEmpty) {
      url += '?' + Uri(queryParameters: params).query;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Stock.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stock movements');
    }
  }

  Future<void> addStockMovement(Stock movement) async {
    final response = await http.post(
      Uri.parse('$baseUrl/GetAll/stockmovements'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(movement.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('فشل في إضافة حركة المخزون');
    }
  }
}
