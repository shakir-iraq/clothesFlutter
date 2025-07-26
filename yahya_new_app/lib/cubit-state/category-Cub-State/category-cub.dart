import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/category.dart';
import 'category-state.dart';
import 'package:yahya_new_app/Controlls/apiCategory.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ApiCategory apiCategory;

  CategoryCubit(this.apiCategory) : super(CategoryInitial());

  Future<void> getCategoriesToFront() async {
    emit(CategoryLoading());
    try {
      final categories = await apiCategory.getAllCategoriesFromApi();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('فشل تحميل التصنيفات'));
    }
  }

  Future<void> createCategoryFromFront(Categorys category) async {
    emit(CategoryLoading());
    try {
      await apiCategory.postCategoryToApi(category);
      await getCategoriesToFront(); // إعادة تحميل التصنيفات بعد الإضافة
    } catch (e) {
      emit(CategoryError('فشل إضافة التصنيف'));
    }
  }

  Future<void> deleteCategory(int id) async {
    emit(CategoryLoading());
    try {
      await ApiCategory().deleteCategory(id);
      emit(CategoryDeleted());
      await getCategoriesToFront();
    } catch (e) {
      emit(CategoryError('فشل في حذف  '));
    }
  }
}
