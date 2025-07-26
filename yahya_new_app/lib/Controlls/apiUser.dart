import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:yahya_new_app/model/user.dart';

class ApiUser {
  static const String baseUrl = 'http://192.168.18.3:7045/api/users';
  // جلب كل المستخدمين
  Future<List<User>> fromApiFetchUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // جلب مستخدم حسب ID
  Future<User> fromApiFetchUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  // إضافة مستخدم جديد مع رفع صورة
  Future<User> fromApiAddUser({
    required String name,
    required String email,
    required String password,
    String? imageFilePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', uri);

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;

    if (kIsWeb) {
      if (imageBytes != null && imageFileName != null) {
        final mimeType = lookupMimeType(imageFileName) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        request.files.add(
          http.MultipartFile.fromBytes(
            'ProfileImage',
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
            'ProfileImage',
            imageFilePath,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          );
          request.files.add(multipartFile);
        }
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('فشل في رفع المستخدم: ${response.body}');
    }
  }

  // تعديل مستخدم
  Future<User> fromApiUpdateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user');
    }
  }

  // حذف مستخدم
  Future<void> fromApiDeleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$userId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // تسجيل الدخول
  Future<User?> fromApiLoginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      return null;
    } else {
      throw Exception('فشل تسجيل الدخول');
    }
  }
}
