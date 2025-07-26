import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiUser.dart'; // API خارجي عبر HTTP
import 'package:yahya_new_app/cubit-state/user-cubit-state/user-state.dart';
import 'package:yahya_new_app/model/user.dart';

class UserCubit extends Cubit<UserState> {
  final ApiUser apiUser;

  UserCubit(this.apiUser) : super(UserInitial());

  Future<void> loginUser(String email, String password) async {
    emit(UserLoading());
    try {
      final user = await apiUser.fromApiLoginUser(email, password);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError('بيانات الدخول غير صحيحة'));
      }
    } catch (e) {
      emit(UserError('فشل في تسجيل الدخول'));
    }
  }

  Future<void> addUser({
    required String name,
    required String email,
    required String password,
    String? imageFilePath,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    emit(UserLoading());
    try {
      final newUser = await apiUser.fromApiAddUser(
        name: name,
        email: email,
        password: password,
        imageFilePath: imageFilePath,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );
      emit(UserLoaded(newUser));
    } catch (e) {
      emit(UserError('فشل إنشاء الحساب: ${e.toString()}'));
    }
  }

  Future<void> loadUser(int id) async {
    emit(UserLoading());
    try {
      final user = await apiUser.fromApiFetchUser(id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('لم يتم العثور على المستخدم'));
    }
  }

  Future<void> updateUser(User user) async {
    emit(UserLoading());
    try {
      final updatedUser = await apiUser.fromApiUpdateUser(user);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError('فشل تعديل المستخدم'));
    }
  }

  Future<void> deleteUser(int id) async {
    emit(UserLoading());
    try {
      await apiUser.fromApiDeleteUser(id);
      emit(UserInitial());
    } catch (e) {
      emit(UserError('فشل حذف المستخدم'));
    }
  }
}
