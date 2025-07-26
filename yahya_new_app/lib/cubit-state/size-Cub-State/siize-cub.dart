import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/size.dart';
import 'siize-state.dart';
import 'package:yahya_new_app/Controlls/apiSiize.dart';

class SiizeCubit extends Cubit<SiizeState> {
  final ApiSiize apiSize;

  SiizeCubit(this.apiSize) : super(SiizeInitial());

  Future<void> getSizeToFront() async {
    emit(SiizeLoading());
    try {
      final size = await apiSize.getAllSizeFromApi();
      emit(SiizeLoaded(size));
    } catch (e) {
      emit(SiizeError('فشل تحميل المقاسات'));
    }
  }

  Future<void> createSizeFromFront(Siize size) async {
    emit(SiizeLoading());
    try {
      await apiSize.postSizeToApi(size);
      await getSizeToFront();
    } catch (e) {
      emit(SiizeError('فشل إضافة المقاس'));
    }
  }

  Future<void> deleteSiize(int id) async {
    emit(SiizeLoading());
    try {
      await ApiSiize().deleteSiize(id);
      emit(SiizeDeleted());
      await getSizeToFront();
    } catch (e) {
      emit(SiizeError('فشل في حذف اللون'));
    }
  }
}
