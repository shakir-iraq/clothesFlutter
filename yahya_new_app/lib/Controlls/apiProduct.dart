import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../model/product.dart';

class ApiProduct {
  static const String baseUrl = 'http://192.168.18.3:7045/api/GetAll';

  // جلب كل المنتجات
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse("$baseUrl/products"));
    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('فشل تحميل المنتجات');
    }
  }

  // جلب منتج حسب ID
  Future<Product> fetchProduct(int productId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$productId'));
    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في تحميل المنتج');
    }
  }

  // إضافة منتج جديد مع رفع صورة (يدعم web و mobile)
  Future<Product> addProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageFilePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    var uri = Uri.parse('$baseUrl/products');
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['categoryId'] = categoryId.toString();

    if (kIsWeb) {
      if (imageBytes != null && imageFileName != null) {
        final mimeType = lookupMimeType(imageFileName) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageFileName,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }
    } else {
      if (imageFilePath != null && imageFilePath.isNotEmpty) {
        final file = File(imageFilePath);
        if (await file.exists()) {
          final mimeType = lookupMimeType(imageFilePath) ?? 'image/jpeg';
          final mimeSplit = mimeType.split('/');
          final multipartFile = await http.MultipartFile.fromPath(
            'image',
            imageFilePath,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          );
          request.files.add(multipartFile);
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في إضافة المنتج: ${response.body}');
    }
  }

  // تعديل منتج مع دعم رفع صورة (اختياري)
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imageFilePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    var uri = Uri.parse('$baseUrl/products/$id');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['id'] = id.toString();
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['categoryId'] = categoryId.toString();

    if (kIsWeb) {
      if (imageBytes != null && imageFileName != null) {
        final mimeType = lookupMimeType(imageFileName) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageFileName,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }
    } else {
      if (imageFilePath != null && imageFilePath.isNotEmpty) {
        final file = File(imageFilePath);
        if (await file.exists()) {
          final mimeType = lookupMimeType(imageFilePath) ?? 'image/jpeg';
          final mimeSplit = mimeType.split('/');
          final multipartFile = await http.MultipartFile.fromPath(
            'image',
            imageFilePath,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          );
          request.files.add(multipartFile);
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في تعديل المنتج: ${response.body}');
    }
  }

  // حذف منتج
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('فشل في حذف المنتج');
    }
  }
}
