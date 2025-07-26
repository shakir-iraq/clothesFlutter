import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahya_new_app/Controlls/apiCoolor.dart';
import 'package:yahya_new_app/cubit-state/color-Cub-State%20copy/coolor-state.dart';

import 'package:yahya_new_app/model/Coolor.dart';

class CoolorCubit extends Cubit<CoolorState> {
  final ApiCoolor apiCoolor;

  CoolorCubit(this.apiCoolor) : super(CoolorInitial());

  Future<void> getcoolorToFront() async {
    emit(CoolorLoading());
    try {
      final coolor = await apiCoolor.getAllCoolorFromApi();
      emit(CoolorLoaded(coolor));
    } catch (e) {
      emit(CoolorError('فشل تحميل الألوان'));
    }
  }

  Future<void> createcoolorFromFront(Coolor coolor) async {
    emit(CoolorLoading());
    try {
      await apiCoolor.postcoolorToApi(coolor);
      await getcoolorToFront(); // إعادة تحميل الألوان بعد الإضافة
    } catch (e) {
      emit(CoolorError('فشل إضافة اللون'));
    }
  }

  Future<void> deleteColor(int id) async {
    emit(CoolorLoading());
    try {
      await ApiCoolor().deleteColor(id);
      emit(CoolorDeleted());
      await getcoolorToFront();
    } catch (e) {
      emit(CoolorError('فشل في حذف اللون'));
    }
  }
}
